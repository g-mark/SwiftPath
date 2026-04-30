//
//  PathNode.swift
//  SwiftPath
//
//  Represents a single node in a compiled JSON Path expression
//
//  Created by Steven Grosmark on 8/20/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import Foundation

// @unchecked Sendable: PathNode is an immutable enum; all associated values are either
// primitive Sendable types or ArrayFilter/FilterExpression with documented safety invariants.
// @unchecked is required to break the circular dependency PathNode → ArrayFilter →
// FilterExpression → JsonPathPart → [PathNode].
internal enum PathNode: Sendable {
    
	/// $
	case root
	
	/// @
	case current
	
	/// .name or ['name']
	/// executed on an object, evaluates to a JsonValue
	/// executed on an array, evaluates to an array of JsonValues
	case property(name: String)
	
	/// ['name1', 'name2']
	/// executed on an object, evaluates to a JsonObject with only those properties
    /// can optionally provide a new name for each property, like this:
    ///   ['name1', 'name2'=>'newName']
    case properties(names: [String], rename:[String])
	
    /// .*
    /// executed on an object
    /// evaluates to an array of JsonValues containing all the values of the object (keys are lost)
    case values
    
	/// [0]; or [-2] (2nd from the end)
	/// executed on an Array, evaluates to a JsonValue
	case arrayItem(index: Int)
	
	/// [0, 1, 3]
	/// executed on an array, evaluates to an array of JsonValues
	case arrayItems(indices: [Int])

	/// [*]
	/// executed on an array, evaluates to the whole array
	case arrayValues
	
	/// [0:3] 0 up to 3;
	///	[:4] 0 up to 4;
	/// [2:] 2 through the end
	///	[-2:] two from the end, through to the end
	/// [1:5:2] 1 up to 5, every second item
	/// executed on an array, evaluates to an array of JsonValues
	case arrayRange(from: Int?, to: Int?, step: Int? = nil)
	
	/// [?(@.name==value)]
	/// executed on an array, evaluates to the items whose filter matches
	case arrayFilter(filter: ArrayFilter)
	
	/// .min()
	/// executed on an array or numbers, evaluates to a number
	case function(function: ArrayFunction)
	
	/// used internally, to support filters
	/// evaluates to the JsonValue stored in a register index
	case registerValue(index: Int)
    
    
    /// used internally
    case noop
    indirect case nodes(nodes: [PathNode])
    indirect case path(base: PathNode, nodes: [PathNode])
}


extension PathNode {
    
	internal func process(with json: JsonValue, registers:[JsonValue]) throws -> JsonValue? {
		switch self {
		
		case .root:
			return registers[0]
		
		case .current:
			return json
		
		case .registerValue(let index):
			return registers[index]
		
		case .property(let name):
			if let node = json as? JsonObject {
				return node[name]
			}
			if let node = json as? JsonArray {
				var result:[JsonValue] = []
				for obj in node {
					if let obj = obj as? JsonObject, let value = obj[name] {
						result.append(value)
					}
				}
				return result
			}
			throw JsonPathEvaluateError.expectingAnObject
		
		case .properties(let names, let rename):
            if let node = json as? JsonObject {
                var reducedObject: JsonObject = [:]
                for (sourceName, targetName) in zip(names, rename) {
                    reducedObject[targetName] = node[sourceName]
                }
                return reducedObject
            }
            guard let array = json as? JsonArray else {
                throw JsonPathEvaluateError.expectingAnArray
            }
            var values = JsonArray()
            for obj in array {
                guard let node = obj as? JsonObject else {
                    throw JsonPathEvaluateError.expectingAnObject
                }
                var reducedObject: JsonObject = [:]
                for (sourceName, targetName) in zip(names, rename) {
                    reducedObject[targetName] = node[sourceName]
                }
                values.append(reducedObject)
            }
            return values
		
        case .values:
            return wildcardValues(from: json)
            
		case .arrayItem(let index):
			guard let node = json as? JsonArray else {
				return JsonArray()
			}
			return node.value(at: index) ?? JsonArray()
		
		case .arrayItems(let indices):
			guard let node = json as? JsonArray else {
				return JsonArray()
			}
			var slice: JsonArray = []
			for idx in indices {
				if let value = node.value(at: idx) {
                    slice.append(value)
                }
			}
			return slice

		case .arrayValues:
			return wildcardValues(from: json)
		
		case .arrayRange(let lowerBound, let upperBound, let step):
			guard let node = json as? JsonArray else {
				return JsonArray()
			}
			return node.slice(from: lowerBound, to: upperBound, by: step ?? 1)

		case .arrayFilter(let filter):
			guard let node = json as? JsonArray else {
				throw JsonPathEvaluateError.expectingAnArray
			}
			var filtered: JsonArray = []
			for item in node {
				if try filter.matches(item) {
					filtered.append(item)
				}
			}
			return filtered
		
		case .function(let function):
			guard let node = json as? JsonArray else {
				throw JsonPathEvaluateError.expectingAnArray
			}
			return try function.evaluate(array: node)
		
        case .noop:
            return json
            
        case .nodes(_), .path(_, _):
            throw JsonPathEvaluateError.unexpectedInternalNode
		}
	}
}

private extension Array where Element == JsonValue {
    
	func slice(from lowerBound: Int?, to upperBound: Int?, by step: Int) -> JsonArray {
		guard step != 0 else { return [] }

		let len = count
		var result = JsonArray()

		if step > 0 {
			let start = lowerBound ?? 0
			let end = upperBound ?? len
			let lower = clamp(normalize(start, length: len), min: 0, max: len)
			let upper = clamp(normalize(end, length: len), min: 0, max: len)
			var index = lower
			while index < upper {
				result.append(self[index])
				index += step
			}
			return result
		}

		let start = lowerBound ?? len - 1
		let end = upperBound ?? -len - 1
		let upper = clamp(normalize(start, length: len), min: -1, max: len - 1)
		let lower = clamp(normalize(end, length: len), min: -1, max: len - 1)
		var index = upper
		while lower < index {
			result.append(self[index])
			index += step
		}
		return result
	}

	func normalize(_ index: Int, length: Int) -> Int {
		return index >= 0 ? index : length + index
	}

	func clamp(_ value: Int, min lowerBound: Int, max upperBound: Int) -> Int {
		return Swift.min(Swift.max(value, lowerBound), upperBound)
	}
}

private func wildcardValues(from json: JsonValue) -> JsonArray {
    if let node = json as? JsonObject {
        return Array(node.values)
    }
    if let node = json as? JsonArray {
        return node
    }
    return []
}

internal struct ArrayFilter: Sendable {
	let expression: FilterExpression

	internal init(path: JsonPathPart) {
		expression = .exists(path)
	}

	internal init(path: JsonPathPart, expectedValue: JsonValue, comparisonOperator: FilterComparisonOperator = .equal) {
		expression = .comparison(path, comparisonOperator, expectedValue)
	}

	internal init(expression: FilterExpression) {
		self.expression = expression
	}

	internal func matches(_ json: JsonValue) throws -> Bool {
		return try expression.matches(json)
	}
}

// @unchecked Sendable: the .comparison case stores a JsonValue (Any) parsed from a
// JSONPath literal — always a primitive (String, Int, Double, Bool) or NSNull,
// immutable after construction.
internal indirect enum FilterExpression: @unchecked Sendable {
	case exists(JsonPathPart)
	case comparison(JsonPathPart, FilterComparisonOperator, JsonValue)
	case not(FilterExpression)
	case and(FilterExpression, FilterExpression)
	case or(FilterExpression, FilterExpression)

	internal func matches(_ json: JsonValue) throws -> Bool {
		switch self {
		case .exists(let path):
			return try path.evaluate(with: json, registers: [json]) != nil
		case .comparison(let path, let comparisonOperator, let expectedValue):
			let value = try path.evaluate(with: json, registers: [json])
			return compare(value, expectedValue, with: comparisonOperator)
		case .not(let expression):
			return try !expression.matches(json)
		case .and(let lhs, let rhs):
			return try lhs.matches(json) && rhs.matches(json)
		case .or(let lhs, let rhs):
			return try lhs.matches(json) || rhs.matches(json)
		}
	}

	private func compare(_ lhs: JsonValue?, _ rhs: JsonValue, with comparisonOperator: FilterComparisonOperator) -> Bool {
		guard lhs != nil else { return false }
		switch comparisonOperator {
		case .equal:
			return valuesEqual(lhs, rhs)
		case .notEqual:
			return !valuesEqual(lhs, rhs)
		case .lessThan:
			guard let comparison = numericComparison(lhs, rhs) else { return false }
			return comparison < 0
		case .lessThanOrEqual:
			guard let comparison = numericComparison(lhs, rhs) else { return false }
			return comparison <= 0
		case .greaterThan:
			guard let comparison = numericComparison(lhs, rhs) else { return false }
			return comparison > 0
		case .greaterThanOrEqual:
			guard let comparison = numericComparison(lhs, rhs) else { return false }
			return comparison >= 0
		}
	}

	private func valuesEqual(_ lhs: JsonValue?, _ rhs: JsonValue) -> Bool {
		guard let lhs = lhs else { return false }

		if lhs is NSNull {
			return rhs is NSNull
		}
		if let rhs = rhs as? String {
			return (lhs as? String) == rhs
		}
		if let rhs = rhs as? Bool {
			return (lhs as? Bool) == rhs
		}
		if let rhs = rhs as? Int {
			if let lhs = lhs as? Int {
				return lhs == rhs
			}
			if let lhs = lhs as? Double {
				return lhs == Double(rhs)
			}
			if let lhs = lhs as? NSNumber {
				return lhs.doubleValue == Double(rhs)
			}
		}
		if let rhs = rhs as? Double {
			if let lhs = lhs as? Double {
				return lhs == rhs
			}
			if let lhs = lhs as? Int {
				return Double(lhs) == rhs
			}
			if let lhs = lhs as? NSNumber {
				return lhs.doubleValue == rhs
			}
		}
		return false
	}

	private func numericComparison(_ lhs: JsonValue?, _ rhs: JsonValue) -> Int? {
		guard let lhsNumber = doubleValue(lhs), let rhsNumber = doubleValue(rhs) else { return nil }
		if lhsNumber < rhsNumber { return -1 }
		if lhsNumber > rhsNumber { return 1 }
		return 0
	}

	private func doubleValue(_ value: JsonValue?) -> Double? {
		if let value = value as? Double {
			return value
		}
		if let value = value as? Int {
			return Double(value)
		}
		if let value = value as? NSNumber {
			return value.doubleValue
		}
		return nil
	}
}

internal enum FilterComparisonOperator {
	case equal
	case notEqual
	case lessThan
	case lessThanOrEqual
	case greaterThan
	case greaterThanOrEqual
}
