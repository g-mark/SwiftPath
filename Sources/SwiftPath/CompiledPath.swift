//
//  CompiledPath.swift
//  SwiftPath
//
//  Created by Steven Grosmark on 8/20/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import Foundation


public struct CompiledPath {
	
	/// the main JsonPath expression, compiled
	private let path: CompiledPathPart
	
	/// paths that need to be pre-computed
	private let precompute: [CompiledPathPart]
	
	internal init(path: CompiledPathPart, precompute:[CompiledPathPart]? = nil) {
		self.path = path
		self.precompute = precompute ?? []
	}
	
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
}



struct CompiledPathPart {
	let parts: [PathNode]
	
	func evaluate(with json:JsonValue, registers:[JsonValue]) throws -> JsonValue? {
		guard parts.count > 0 else { throw JsonPathEvaluateError.emptyPath }
		var current:JsonValue?
		
		switch parts[0] {
		case .root: current = registers[0]
		case .current: current = json
		default: throw JsonPathEvaluateError.invalidPathStart
		}
		
		for node in parts[1...] {
			guard let value = current else { throw JsonPathEvaluateError.expectingSomethingNotNil }
			current = try node.process(with: value, registers: registers)
		}
		
		return current
	}
}
