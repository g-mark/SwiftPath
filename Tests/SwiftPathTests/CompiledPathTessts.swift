//
//  CompiledPathTessts.swift
//  SwiftPathTests
//
//  Created by Steven Grosmark on 8/20/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import Foundation
import Testing
@testable import SwiftPath

@Suite(.serialized)
struct CompiledPathTessts {
	
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
	@Test
    func testSimplePathValid() {
		let nodes: [PathNode] = [.root, .property(name: "books"), .arrayItem(index: 1), .property(name:"author")]
		let compiledPart = JsonPathPart(parts: nodes)
		runTest("simple path") {
			let result = try compiledPart.evaluate(with: bookList, registers: [bookList])
			try Expecting.string("Neal Stephenson", result: result)
		}
    }
	
	/// $.books.price.sum()
	@Test
	func testCollatePropertyOnArray() {
		let nodes: [PathNode] = [.root, .property(name: "books"), .property(name:"price"), .function(function: .sum)]
		let compiledPart = JsonPathPart(parts: nodes)
		runTest("path with collated property") {
			let result = try compiledPart.evaluate(with: bookList, registers: [bookList])
			try Expecting.number(59.68, result: result)
		}
	}

	@Test
	func testArrayWildcardPath() {
		runTest("array wildcard path") {
			let path = try #require(JsonPath("$.books[*]"), "expected path to parse")
			let result = try path.evaluate(with: bookList)
			let array = try #require(result as? JsonArray, "expected an array result")
			#expect(array.count == 5)
		}
	}

	@Test
	func testArraySlicePaths() {
		runTest("array slice paths") {
			let bounded = try titles(path: "$.books[1:3]")
			let openStart = try titles(path: "$.books[:3]")
			let openEnd = try titles(path: "$.books[2:]")
			let negativeStart = try titles(path: "$.books[-2:]")
			let stepped = try titles(path: "$.books[1:5:2]")
			let reversed = try titles(path: "$.books[::-1]")
			let clamped = try titles(path: "$.books[-99:99]")
			let startPastEnd = try titles(path: "$.books[99:100]")
			let emptyForward = try titles(path: "$.books[4:1]")
			let zeroStep = try titles(path: "$.books[::0]")
			let clampedReverse = try titles(path: "$.books[10:-10:-2]")

			#expect(bounded == ["Snow Crash", "Do Androids Dream of Electric Sheep?"])
			#expect(openStart == ["Ready Player One", "Snow Crash", "Do Androids Dream of Electric Sheep?"])
			#expect(openEnd == ["Do Androids Dream of Electric Sheep?", "Slaughterhouse-Five", "Oryx and Crake"])
			#expect(negativeStart == ["Slaughterhouse-Five", "Oryx and Crake"])
			#expect(stepped == ["Snow Crash", "Slaughterhouse-Five"])
			#expect(reversed == ["Oryx and Crake", "Slaughterhouse-Five", "Do Androids Dream of Electric Sheep?", "Snow Crash", "Ready Player One"])
			#expect(clamped == ["Ready Player One", "Snow Crash", "Do Androids Dream of Electric Sheep?", "Slaughterhouse-Five", "Oryx and Crake"])
			#expect(startPastEnd == [])
			#expect(emptyForward == [])
			#expect(zeroStep == [])
			#expect(clampedReverse == ["Oryx and Crake", "Do Androids Dream of Electric Sheep?", "Ready Player One"])
		}
	}

	@Test
	func testArrayFilterPath() {
		runTest("array filter path") {
			let path = try #require(JsonPath("$.books[?(@.id==5)]"), "expected path to parse")
			let result = try path.evaluate(with: bookList)
			let array = try #require(result as? JsonArray, "expected an array result")
			#expect(array.count == 1)
			let object = try #require(array[0] as? JsonObject, "expected an object result")
			#expect(object["id"] as? Int == 5)
		}
	}

	@Test
	func testArrayFilterStringLiteralPath() {
		runTest("array filter string literal path") {
			let result = try filterResult(path: "$.books[?(@.title == 'Snow Crash')]")
			#expect(result.count == 1)
			#expect((result[0] as? JsonObject)?["id"] as? Int == 2)
		}
	}

	@Test
	func testArrayFilterBoolLiteralPath() {
		runTest("array filter bool literal path") {
			let result = try filterResult(path: "$.books[?(@.available == true)]")
			#expect(result.count == 3)
		}
	}

	@Test
	func testArrayFilterNullLiteralPath() {
		runTest("array filter null literal path") {
			let result = try filterResult(path: "$.books[?(@.isbn == null)]")
			#expect(result.count == 1)
			#expect((result[0] as? JsonObject)?["id"] as? Int == 5)
		}
	}

	@Test
	func testArrayFilterComparisonOperators() {
		runTest("array filter comparison operators") {
			let notFive = try filterResult(path: "$.books[?(@.id != 5)]")
			let belowTen = try filterResult(path: "$.books[?(@.price < 10.0)]")
			let atMostNineNinetyNine = try filterResult(path: "$.books[?(@.price <= 9.99)]")
			let aboveThirteenEightyNine = try filterResult(path: "$.books[?(@.price > 13.89)]")
			let atLeastThirteenEightyNine = try filterResult(path: "$.books[?(@.price >= 13.89)]")

			#expect(notFive.count == 4)
			#expect(belowTen.count == 2)
			#expect(atMostNineNinetyNine.count == 2)
			#expect(aboveThirteenEightyNine.count == 1)
			#expect(atLeastThirteenEightyNine.count == 2)
		}
	}

	@Test
	func testArrayFilterExistencePath() {
		runTest("array filter existence path") {
			let booksWithIsbn = try filterResult(path: "$.books[?(@.isbn)]")
			let booksWithMissingProperty = try filterResult(path: "$.books[?(@.missing)]")

			#expect(booksWithIsbn.count == 5)
			#expect(booksWithMissingProperty.count == 0)
		}
	}

	@Test
	func testArrayFilterLogicalAndPath() {
		runTest("array filter logical and path") {
			let result = try filterResult(path: "$.books[?(@.available == true && @.price < 12.0)]")
			#expect(result.count == 2)
		}
	}

	@Test
	func testArrayFilterLogicalOrPath() {
		runTest("array filter logical or path") {
			let result = try filterResult(path: "$.books[?(@.id == 1 || @.id == 2)]")
			#expect(result.count == 2)
		}
	}

	@Test
	func testArrayFilterLogicalNotPath() {
		runTest("array filter logical not path") {
			let result = try filterResult(path: "$.books[?(!(@.available == true))]")
			#expect(result.count == 2)
		}
	}

	@Test
	func testArrayFilterQuotedPropertyPath() {
		runTest("array filter quoted property path") {
			let result = try filterResult(path: "$.books[?(@['id'] == 5)]")
			#expect(result.count == 1)
			#expect((result[0] as? JsonObject)?["title"] as? String == "Oryx and Crake")
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

	private func titles(path: String) throws -> [String] {
		guard let path = JsonPath(path) else {
			throw TestError(message: "expected path to parse")
		}
		guard let array = try path.evaluate(with: bookList) as? JsonArray else {
			throw TestError(message: "expected array result")
		}
		return array.compactMap { ($0 as? JsonObject)?["title"] as? String }
	}
    
}
