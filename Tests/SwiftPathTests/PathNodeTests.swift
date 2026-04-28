//
//  PathNodeTests.swift
//  SwiftPathTests
//
//  Created by Steven Grosmark on 8/20/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import Testing
@testable import SwiftPath

@Suite(.serialized)
struct PathNodeTests {
	
	let jsonObject: JsonObject = ["name":"the name value", "summary": "the summary value", "three": "the three value"]
	let jsonArray: JsonArray = [ "zero", "one", "two", "three", "four"]
	let numberArray: JsonArray = [ 2.0, 4.0, 6.0 ]
	
    @Test
    func testProperty() {
		let node = PathNode.property(name: "summary")
		runTest("property") {
			let result = try node.process(with: jsonObject, registers: [])
			try Expecting.string("the summary value", result: result)
		}
    }
    
    @Test
    func testProperyValues() {
        let node = PathNode.values
        runTest("property values") {
            let result = try node.process(with: jsonObject, registers: [])
            try Expecting.array(["the name value", "the summary value", "the three value"], ordered: false, result: result)
        }
    }
	
	@Test
	func testCollatedProperty() {
		var array: JsonArray = []
		for i in 1...4 {
			let obj:JsonObject = [ "key" : "value\(i)", "index": i ]
			array.append( obj )
		}
		let node = PathNode.property(name: "key")
		runTest("collated property") {
			let result = try node.process(with: array, registers: [])
			try Expecting.array(["value1", "value2", "value3", "value4"], result: result)
		}
	}
	
	@Test
	func testPropertyList() {
        let node = PathNode.properties(names: ["summary", "three"], rename: ["summary", "third"])
		runTest("property list") {
			let result = try node.process(with: jsonObject, registers: [])
			try Expecting.object(["summary":"the summary value", "third":"the three value"], result: result)
		}
	}
	
	/// [1]
	@Test
	func testArrayItem() {
		let node = PathNode.arrayItem(index: 1)
		runTest("array item") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.string("one", result: result)
		}
	}
	
	/// [-2]
	@Test
	func testArrayItemFromEnd() {
		let node = PathNode.arrayItem(index: -2)
		runTest("array item") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.string("three", result: result)
		}
	}
	
	/// [1, 3]
	@Test
	func testArrayItems() {
		let node = PathNode.arrayItems(indices: [1, 3])
		runTest("array items") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.array(["one", "three"], result: result)
		}
	}
	
	/// [1:3] 1 up to 3 (exclusive);
	@Test
	func testSimpleArrayRange() {
		let node = PathNode.arrayRange(from: 1, to: 3)
		runTest("simple array range") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.array(["one", "two"], result: result)
		}
	}
	
	///	[:3] 0 up to 3
	@Test
	func testOpenStartArrayRange() {
		let node = PathNode.arrayRange(from: nil, to: 3)
		runTest("array range with open start") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.array(["zero", "one", "two"], result: result)
		}
	}
	
	/// [2:] 2 through the end
	@Test
	func testOpenEndArrayRange() {
		let node = PathNode.arrayRange(from: 2, to: nil)
		runTest("array range with open end") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.array(["two", "three", "four"], result: result)
		}
	}
	
	/// [-2:] 2nd from the end, through to the end
	@Test
	func testOpenEndArrayRangeFromEnd() {
		let node = PathNode.arrayRange(from: -2, to: nil)
		runTest("array range with open end (negative start)") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.array(["three", "four"], result: result)
		}
	}

	/// [1:5:2] 1 up to 5, every second item
	@Test
	func testArrayRangeWithStep() {
		let node = PathNode.arrayRange(from: 1, to: 5, step: 2)
		runTest("array range with step") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.array(["one", "three"], result: result)
		}
	}

	/// [::-1] all items in reverse order
	@Test
	func testArrayRangeWithNegativeStep() {
		let node = PathNode.arrayRange(from: nil, to: nil, step: -1)
		runTest("array range with negative step") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.array(["four", "three", "two", "one", "zero"], result: result)
		}
	}

	@Test
	func testArrayRangeClampsOutOfBounds() {
		let node = PathNode.arrayRange(from: -10, to: 10)
		runTest("array range clamps out of bounds") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.array(["zero", "one", "two", "three", "four"], result: result)
		}
	}

	@Test
	func testArrayRangeReturnsEmptyWhenBoundsDoNotIterate() {
		let node = PathNode.arrayRange(from: 4, to: 1)
		runTest("array range returns empty") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.array([], result: result)
		}
	}

	@Test
	func testArrayRangeReturnsEmptyForZeroStep() {
		let node = PathNode.arrayRange(from: nil, to: nil, step: 0)
		runTest("array range returns empty for zero step") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.array([], result: result)
		}
	}

	@Test
	func testReverseArrayRangeClampsOutOfBounds() {
		let node = PathNode.arrayRange(from: 10, to: -10, step: -2)
		runTest("reverse array range clamps out of bounds") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.array(["four", "two", "zero"], result: result)
		}
	}
	
	@Test
	func testFunction() {
		let node = PathNode.function(function: .average)
		runTest("function") {
			let result = try node.process(with: numberArray, registers: [])
			try Expecting.number(4, result: result)
		}
	}
	
	@Test
	func testRegister() {
		let node = PathNode.registerValue(index: 1)
		runTest("function") {
			let result = try node.process(with: jsonObject, registers: [jsonObject, "precalculated"])
			try Expecting.string("precalculated", result: result)
		}
	}

	@Test
	func testArrayFilter() {
		let filter = ArrayFilter(path: JsonPathPart(parts: [.current, .property(name: "index")]), expectedValue: 3)
		let node = PathNode.arrayFilter(filter: filter)
		let array: JsonArray = [
			["index": 1, "key": "one"],
			["index": 3, "key": "three"]
		]
		runTest("array filter") {
			let result = try node.process(with: array, registers: [])
			guard let filtered = result as? JsonArray else {
				Issue.record("expected an array result")
				return
			}
			#expect(filtered.count == 1)
			guard let object = filtered[0] as? JsonObject else {
				Issue.record("expected an object result")
				return
			}
			#expect(object["key"] as? String == "three")
		}
	}

    
}
