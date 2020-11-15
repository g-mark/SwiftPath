//
//  TestHelpers.swift
//  JsonPathLibTests
//
//  Created by Steven Grosmark on 8/20/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import XCTest
@testable import SwiftPath


func runTest(_ name:String, test: () throws -> Void) {
	do {
		try test()
	}
	catch {
		XCTFail("error running \(name) test: \(error)")
	}
}

extension String: Error {
}

class Expecting {
	
	static func object(_ object:[String:String], result inResult:JsonValue?) throws {
		guard let result = inResult as? JsonObject else {
			throw "property result not an object \(String(describing: inResult))"
		}
		guard result.count == object.count else {
			throw "property result has wrong key count: expecting \(object.count) found \(result.count)"
		}
		for (key, value) in object {
			guard let resultValue = result[key] as? String else {
				throw "invalid value for key \"\(key)\" (expecting \"\(key)\", got:: \(String(describing: result[key]))"
			}
			if value != resultValue {
				throw "value mismatch for key \"\(key)\" - expecting \"\(value)\" got \"\(resultValue)\""
			}
		}
	}
	
	static func string(_ string: String, result inResult:JsonValue?) throws {
		guard let result = inResult as? String else {
			throw "property result not an string \(String(describing: inResult))"
		}
		if string != result {
			throw "string mismatch - expecting \"\(string)\" got \"\(result)\""
		}
	}
	
	static func number(_ number: Double, result inResult:JsonValue?) throws {
		guard let result = inResult as? Double else {
			throw "property result not a double \(String(describing: inResult))"
		}
		if number != result {
			throw "number mismatch - expecting \(number) got \(result)"
		}
	}
	
    static func array(_ array:[String], ordered: Bool = true, result inResult:JsonValue?) throws {
		guard let result = inResult as? JsonArray else {
			throw "property result not an array \(String(describing: inResult))"
		}
		guard result.count == array.count else {
			throw "property result has wrong count: expecting \(array.count) found \(result.count)"
		}
        if ordered {
            for (idx, resultItem) in result.enumerated() {
                if let value = resultItem as? String {
                    if array[idx] != value {
                        throw "string mismatch - expecting \"\(array[idx])\" got \"\(value)\""
                    }
                }
                else {
                    throw "property result item isn't a string: \(resultItem)"
                }
            }
        }
        else {
            let expectedSet = array.countedSet()
            let resultSet = result.countedSet()
            if expectedSet != resultSet {
                throw "unordered arrays don't match"
            }
        }
	}
}

extension Array where Element: Any {
    func countedSet() -> NSCountedSet {
        return self.reduce(into: NSCountedSet()) { $0.add($1) }
    }
}

