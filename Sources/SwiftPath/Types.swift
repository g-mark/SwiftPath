//
//  Types.swift
//  SwiftPath
//
//  Created by Steven Grosmark on 8/20/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import Foundation

public typealias JsonValue = Any
public typealias JsonObject = [String:JsonValue]
public typealias JsonArray = [JsonValue]


internal extension Array where Element == JsonValue {
	func value(at index: Int) throws -> JsonValue {
		// negative index counts from the end
		if index < 0 && abs(index) < count {
			return self[count + index]
		}
		if index < count {
			return self[index]
		}
		throw JsonPathEvaluateError.indexOutOfBounds
	}
}
