//
//  Errors.swift
//  SwiftPath
//
//  Created by Steven Grosmark on 8/20/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import Foundation

public enum JsonPathEvaluateError: Error {
	case emptyPath
	case invalidPathStart
	case expectingSomethingNotNil
	case expectingAnObject
	case expectingAnArray
	case expectingAnArrayWithSomeValues
	case expectingAnArrayWithTwoOrMoreValues
	case expectingANumber
	case invalidNode
	case evaluateSubPathFailed
	case indexOutOfBounds
    case unexpectedInternalNode
    case invalidJSONString
    
    public var localizedDescription: String {
        switch self {
        case .emptyPath: return "empty path"
        case .invalidPathStart: return "invalid path start"
        case .expectingSomethingNotNil: return "expecting something other than nil"
        case .expectingAnObject: return "was expecting an object"
        case .expectingAnArray: return "was expecting an array"
        case .expectingAnArrayWithSomeValues: return "was expecting a non-empty array"
        case .expectingAnArrayWithTwoOrMoreValues: return "was expecting an array with at least two values"
        case .expectingANumber: return "was expecting a number"
        case .invalidNode: return "invalid node"
        case .evaluateSubPathFailed: return "failed to evaluate sub-path"
        case .indexOutOfBounds: return "array index out of bounds"
        case .unexpectedInternalNode: return "unexpected internal node"
        case .invalidJSONString: return "invalid input json string"
            
        }
    }
}
