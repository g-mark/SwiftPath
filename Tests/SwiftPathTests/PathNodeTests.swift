//
//  PathNodeTests.swift
//  JsonPathLibTests
//
//  Created by Steven Grosmark on 8/20/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import XCTest
@testable import SwiftPath

class PathNodeTests: XCTestCase {
	
	let jsonObject: JsonObject = ["name":"the name value", "summary": "the summary value", "three": "the three value"]
	let jsonArray: JsonArray = [ "zero", "one", "two", "three", "four"]
	let numberArray: JsonArray = [ 2.0, 4.0, 6.0 ]
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testProperty() {
		let node = PathNode.property(name: "summary")
		runTest("property") {
			let result = try node.process(with: jsonObject, registers: [])
			try Expecting.string("the summary value", result: result)
		}
    }
	
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
	
	func testPropertyList() {
		let node = PathNode.properties(names: ["summary", "three"])
		runTest("property list") {
			let result = try node.process(with: jsonObject, registers: [])
			try Expecting.object(["summary":"the summary value", "three":"the three value"], result: result)
		}
	}
	
	/// [1]
	func testArrayItem() {
		let node = PathNode.arrayItem(index: 1)
		runTest("array item") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.string("one", result: result)
		}
	}
	
	/// [-2]
	func testArrayItemFromEnd() {
		let node = PathNode.arrayItem(index: -2)
		runTest("array item") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.string("three", result: result)
		}
	}
	
	/// [1, 3]
	func testArrayItems() {
		let node = PathNode.arrayItems(indices: [1, 3])
		runTest("array items") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.array(["one", "three"], result: result)
		}
	}
	
	/// [1:3] 1 up to 3 (exclusive);
	func testSimpleArrayRange() {
		let node = PathNode.arrayRange(from: 1, to: 3)
		runTest("simple array range") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.array(["one", "two"], result: result)
		}
	}
	
	///	[:3] 0 up to 3
	func testOpenStartArrayRange() {
		let node = PathNode.arrayRange(from: nil, to: 3)
		runTest("array range with open start") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.array(["zero", "one", "two"], result: result)
		}
	}
	
	/// [2:] 2 through the end
	func testOpenEndArrayRange() {
		let node = PathNode.arrayRange(from: 2, to: nil)
		runTest("array range with open end") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.array(["two", "three", "four"], result: result)
		}
	}
	
	/// [-2:] 2nd from the end, through to the end
	func testOpenEndArrayRangeFromEnd() {
		let node = PathNode.arrayRange(from: -2, to: nil)
		runTest("array range with open end (negative start)") {
			let result = try node.process(with: jsonArray, registers: [])
			try Expecting.array(["three", "four"], result: result)
		}
	}
	
	func testFunction() {
		let node = PathNode.function(function: .average)
		runTest("function") {
			let result = try node.process(with: numberArray, registers: [])
			try Expecting.number(4, result: result)
		}
	}
	
	func testRegister() {
		let node = PathNode.registerValue(index: 1)
		runTest("function") {
			let result = try node.process(with: jsonObject, registers: [jsonObject, "precalculated"])
			try Expecting.string("precalculated", result: result)
		}
	}
	
	
	///TODO: case arrayFilter
	
	
    
}
