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

internal enum PathNode {
    
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
	/// executed on an array, evaluates to an array of JsonValues
	case arrayRange(from: Int?, to: Int?)
	
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
            guard let node = json as? JsonObject else {
                throw JsonPathEvaluateError.expectingAnObject
            }
            return Array(node.values)
            
		case .arrayItem(let index):
			guard let node = json as? JsonArray else {
				throw JsonPathEvaluateError.expectingAnArray
			}
			return try node.value(at: index)
		
		case .arrayItems(let indices):
			guard let node = json as? JsonArray else {
				throw JsonPathEvaluateError.expectingAnArray
			}
			var slice: JsonArray = []
			for idx in indices {
				slice.append(try node.value(at: idx))
			}
			return slice

		case .arrayValues:
			guard let node = json as? JsonArray else {
				throw JsonPathEvaluateError.expectingAnArray
			}
			return node
		
		case .arrayRange(let lowerBound, let upperBound):
			guard let node = json as? JsonArray else {
				throw JsonPathEvaluateError.expectingAnArray
			}
			var lb = lowerBound ?? 0
			var ub = upperBound ?? node.count
			if lb < 0 {
				lb += node.count
			}
			if ub < 0 {
				ub += node.count
			}
			guard lb >= 0 && lb < ub && ub <= node.count else {
				throw JsonPathEvaluateError.indexOutOfBounds
			}
			return Array(node[lb..<ub])

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

internal struct ArrayFilter {
	let path: JsonPathPart
	let expectedValue: JsonValue

	internal func matches(_ json: JsonValue) throws -> Bool {
		let value = try path.evaluate(with: json, registers: [json])
		return valuesEqual(value, expectedValue)
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
}
