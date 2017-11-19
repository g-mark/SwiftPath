//
//  SwiftPath.swift
//  SwiftPath
//
//  Created by Steven Grosmark on 8/20/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import Foundation


public struct SwiftPath {
    
    /// create a SwiftPath from a JSONPath string
    /// will fail if the json path is invalid
    ///
    /// typical usage:
    ///     if let path = SwiftPath("$.books[0].author") {
    ///         let author = path.evaluate(with: someJsonFromTheWebs)
    ///     }
    ///
    public init?(_ path: String) {
        guard let node = PathParser.parse(path: path) else { return nil }
        guard case let .path(base, parts) = node else { return nil }
        self.path = SwiftPathPart(parts: [base] + parts)
        self.precompute = []
    }
    
    /// evaluate the SwiftPath on the specified JSON value
    public func evaluate(with json:JsonValue) throws -> JsonValue? {
        var registers = [json]
        for part in precompute {
            guard let value = try part.evaluate(with: json, registers: registers) else {
                throw JsonPathEvaluateError.evaluateSubPathFailed
            }
            registers.append(value)
        }
        return try path.evaluate(with: json, registers: registers)
    }
    
    public func evaluate(with string:String) throws -> JsonValue? {
        guard let data = string.data(using: String.Encoding.utf8 ) else {
            throw JsonPathEvaluateError.invalidJSONString;
        }
        let json = try JSONSerialization.jsonObject(with: data)
        return try evaluate(with: json)
    }
	
    
	/// the main JsonPath expression, compiled
	private let path: SwiftPathPart
	
	/// paths that need to be pre-computed
	private let precompute: [SwiftPathPart]
	
	internal init(path: SwiftPathPart, precompute:[SwiftPathPart]? = nil) {
		self.path = path
		self.precompute = precompute ?? []
	}
}



internal struct SwiftPathPart {
	let parts: [PathNode]
	
	internal func evaluate(with json:JsonValue, registers:[JsonValue]) throws -> JsonValue? {
		guard parts.count > 0 else { throw JsonPathEvaluateError.emptyPath }
		var current:JsonValue?
		
		switch parts[0] {
		case .root: current = registers[0]
		case .current: current = json
		default: throw JsonPathEvaluateError.invalidPathStart
		}
		
		for node in parts[1...] {
            guard let value = current else {
                // no json to continue from, return nil
                return nil
            }
			current = try node.process(with: value, registers: registers)
		}
		
		return current
	}
}
