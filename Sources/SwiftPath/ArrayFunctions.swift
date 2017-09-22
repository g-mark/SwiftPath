//
//  ArrayFunctions.swift
//  SwiftPath
//
//  Created by Steven Grosmark on 8/20/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import Foundation

internal enum ArrayFunction {
	
	/// smallest value  requires an array of Doubles where count > 0
	case minimum
	
	/// largest value  requires an array of Doubles where count > 0
	case maximum
	
	/// average of array values  requires an array of Doubles where count > 0
	case average
	
	/// sum of array values  requires an array of Doubles
	case sum
	
	/// standard deviation of array values  requires an array of Doubles where count > 1
	case standardDeviation
	
	/// array length  requires an array
	case length
}

internal extension ArrayFunction {
	func evaluate(array: JsonArray) throws -> JsonValue {
		switch self {
		
		case .minimum:
			guard array.count > 0 else { throw JsonPathEvaluateError.expectingAnArrayWithSomeValues }
			let doubles: [Double] = array.flatMap({ $0 as? Double })
			guard doubles.count == array.count else { throw JsonPathEvaluateError.expectingANumber }
			return doubles.reduce(doubles[0], { $0 < $1 ? $0 : $1 })
		
		case .maximum:
			guard array.count > 0 else { throw JsonPathEvaluateError.expectingAnArrayWithSomeValues }
			let doubles: [Double] = array.flatMap({ $0 as? Double })
			guard doubles.count == array.count else { throw JsonPathEvaluateError.expectingANumber }
			return doubles.reduce(doubles[0], { $0 > $1 ? $0 : $1 })
		
		case .average:
			guard array.count > 0 else { throw JsonPathEvaluateError.expectingAnArrayWithSomeValues }
			let doubles: [Double] = array.flatMap({ $0 as? Double })
			guard doubles.count == array.count else { throw JsonPathEvaluateError.expectingANumber }
			return doubles.reduce(0, {$0 + $1}) / Double(doubles.count)
		
		case .sum:
			let doubles: [Double] = array.flatMap({ $0 as? Double })
			guard doubles.count == array.count else { throw JsonPathEvaluateError.expectingANumber }
			return doubles.reduce(0, {$0 + $1})
		
		case .standardDeviation:
			guard array.count >= 2 else { throw JsonPathEvaluateError.expectingAnArrayWithTwoOrMoreValues }
			let doubles: [Double] = array.flatMap({ $0 as? Double })
			guard doubles.count == array.count else { throw JsonPathEvaluateError.expectingANumber }
			let length = Double(doubles.count)
			let avg = doubles.reduce(0, {$0 + $1}) / length
			let sumOfSquaredAvgDiff = doubles.map { pow($0 - avg, 2.0)}.reduce(0, {$0 + $1})
			return sqrt(sumOfSquaredAvgDiff / length)
		
		case .length:
			return Double(array.count)
		}
	}
}
