//
//  CompiledPathTessts.swift
//  JsonPathLibTests
//
//  Created by Steven Grosmark on 8/20/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import XCTest
@testable import SwiftPath

class CompiledPathTessts: XCTestCase {
	
	let bookList: JsonObject = [
        "books": [
            ["id": 1, "title": "Ready Player One", "author": "Ernest Cline", "isbn": "978-0307887436", "price": 9.99],
            ["id": 2, "title": "Snow Crash", "author": "Neal Stephenson", "isbn": "0-553-08853-X", "price": 14.95],
            ["id": 3, "title": "Do Androids Dream of Electric Sheep?", "author": "Philip K. Dick", "isbn": "978-0345404473", "price": 11.89],
            ["id": 4, "title": "Slaughterhouse-Five", "author": "Kurt Vonnegut", "isbn": "9780812417753", "price": 8.96],
            ["id": 5, "title": "Oryx and Crake", "author": "Margaret Atwood", "isbn": "978-0385503853", "price": 13.89]
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
    
}
