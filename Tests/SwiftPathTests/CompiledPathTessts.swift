//
//  CompiledPathTessts.swift
//  SwiftPathTests
//
//  Created by Steven Grosmark on 8/20/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import XCTest
@testable import SwiftPath

class CompiledPathTessts: XCTestCase {
	
	let bookList: JsonObject = [
        "books": [
            ["id": 1, "title": "Ready Player One", "author": "Ernest Cline", "isbn": "978-0307887436", "price": 9.99, "available": true],
            ["id": 2, "title": "Snow Crash", "author": "Neal Stephenson", "isbn": "0-553-08853-X", "price": 14.95, "available": false],
            ["id": 3, "title": "Do Androids Dream of Electric Sheep?", "author": "Philip K. Dick", "isbn": "978-0345404473", "price": 11.89, "available": true],
            ["id": 4, "title": "Slaughterhouse-Five", "author": "Kurt Vonnegut", "isbn": "9780812417753", "price": 8.96, "available": false],
            ["id": 5, "title": "Oryx and Crake", "author": "Margaret Atwood", "isbn": NSNull(), "price": 13.89, "available": true]
        ]
    ]
	
	/// $.books[1].author
    func testSimplePathValid() {
		let nodes: [PathNode] = [.root, .property(name: "books"), .arrayItem(index: 1), .property(name:"author")]
		let compiledPart = JsonPathPart(parts: nodes)
		runTest("simple path") {
			let result = try compiledPart.evaluate(with: bookList, registers: [bookList])
			try Expecting.string("Neal Stephenson", result: result)
		}
    }
	
	/// $.books.price.sum()
	func testCollatePropertyOnArray() {
		let nodes: [PathNode] = [.root, .property(name: "books"), .property(name:"price"), .function(function: .sum)]
		let compiledPart = JsonPathPart(parts: nodes)
		runTest("path with collated property") {
			let result = try compiledPart.evaluate(with: bookList, registers: [bookList])
			try Expecting.number(59.68, result: result)
		}
	}

	func testArrayWildcardPath() {
		runTest("array wildcard path") {
			guard let path = JsonPath("$.books[*]") else {
				XCTFail("expected path to parse")
				return
			}
			let result = try path.evaluate(with: bookList)
			guard let array = result as? JsonArray else {
				XCTFail("expected an array result")
				return
			}
			XCTAssertEqual(array.count, 5)
		}
	}

	func testArrayFilterPath() {
		runTest("array filter path") {
			guard let path = JsonPath("$.books[?(@.id==5)]") else {
				XCTFail("expected path to parse")
				return
			}
			let result = try path.evaluate(with: bookList)
			guard let array = result as? JsonArray else {
				XCTFail("expected an array result")
				return
			}
			XCTAssertEqual(array.count, 1)
			guard let object = array[0] as? JsonObject else {
				XCTFail("expected an object result")
				return
			}
			XCTAssertEqual(object["id"] as? Int, 5)
		}
	}

	func testArrayFilterStringLiteralPath() {
		runTest("array filter string literal path") {
			let result = try filterResult(path: "$.books[?(@.title == 'Snow Crash')]")
			XCTAssertEqual(result.count, 1)
			XCTAssertEqual((result[0] as? JsonObject)?["id"] as? Int, 2)
		}
	}

	func testArrayFilterBoolLiteralPath() {
		runTest("array filter bool literal path") {
			let result = try filterResult(path: "$.books[?(@.available == true)]")
			XCTAssertEqual(result.count, 3)
		}
	}

	func testArrayFilterNullLiteralPath() {
		runTest("array filter null literal path") {
			let result = try filterResult(path: "$.books[?(@.isbn == null)]")
			XCTAssertEqual(result.count, 1)
			XCTAssertEqual((result[0] as? JsonObject)?["id"] as? Int, 5)
		}
	}

	func testArrayFilterComparisonOperators() {
		runTest("array filter comparison operators") {
			XCTAssertEqual(try filterResult(path: "$.books[?(@.id != 5)]").count, 4)
			XCTAssertEqual(try filterResult(path: "$.books[?(@.price < 10.0)]").count, 2)
			XCTAssertEqual(try filterResult(path: "$.books[?(@.price <= 9.99)]").count, 2)
			XCTAssertEqual(try filterResult(path: "$.books[?(@.price > 13.89)]").count, 1)
			XCTAssertEqual(try filterResult(path: "$.books[?(@.price >= 13.89)]").count, 2)
		}
	}

	func testArrayFilterExistencePath() {
		runTest("array filter existence path") {
			XCTAssertEqual(try filterResult(path: "$.books[?(@.isbn)]").count, 5)
			XCTAssertEqual(try filterResult(path: "$.books[?(@.missing)]").count, 0)
		}
	}

	func testArrayFilterLogicalAndPath() {
		runTest("array filter logical and path") {
			let result = try filterResult(path: "$.books[?(@.available == true && @.price < 12.0)]")
			XCTAssertEqual(result.count, 2)
		}
	}

	func testArrayFilterLogicalOrPath() {
		runTest("array filter logical or path") {
			let result = try filterResult(path: "$.books[?(@.id == 1 || @.id == 2)]")
			XCTAssertEqual(result.count, 2)
		}
	}

	func testArrayFilterLogicalNotPath() {
		runTest("array filter logical not path") {
			let result = try filterResult(path: "$.books[?(!(@.available == true))]")
			XCTAssertEqual(result.count, 2)
		}
	}

	func testArrayFilterQuotedPropertyPath() {
		runTest("array filter quoted property path") {
			let result = try filterResult(path: "$.books[?(@['id'] == 5)]")
			XCTAssertEqual(result.count, 1)
			XCTAssertEqual((result[0] as? JsonObject)?["title"] as? String, "Oryx and Crake")
		}
	}

	private func filterResult(path: String) throws -> JsonArray {
		guard let path = JsonPath(path) else {
			throw TestError(message: "expected path to parse")
		}
		guard let array = try path.evaluate(with: bookList) as? JsonArray else {
			throw TestError(message: "expected array result")
		}
		return array
	}
    
}
