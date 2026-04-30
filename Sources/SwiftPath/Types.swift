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


extension Array where Element == JsonValue {
    
	internal func value(at index: Int) -> JsonValue? {
        let normalizedIndex = index >= 0 ? index : count + index
        guard normalizedIndex >= 0, normalizedIndex < count else {
            return nil
        }
		return self[normalizedIndex]
	}
    
    internal func doubles() throws -> [Double] {
        let doubles: [Double] = self.compactMap { $0 as? Double }
        guard doubles.count == self.count else { throw JsonPathEvaluateError.expectingANumber }
        return doubles
    }
    
}

// MARK: - Backwards compatibility

#if swift(>=4.1)
#else
extension Sequence {
    
    public func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        return try flatMap(transform)
    }
    
}
#endif
