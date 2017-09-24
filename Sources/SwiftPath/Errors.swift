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
}
