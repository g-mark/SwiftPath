//
//  CompiledPathTessts.swift
//  JsonPathLibTests
//
//  Created by Steven Grosmark on 8/20/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import XCTest
@testable import JsonPathLib

class CompiledPathTessts: XCTestCase {
	
	var bookList:JsonObject!
	
    override func setUp() {
        super.setUp()
		let book1: JsonObject = [ "title": "Ready Player One", "author": "Ernest Cline", "isbn": "978-0307887436", "price": 9.99 ]
		let book2: JsonObject = [ "title": "Snow Crash", "author": "Neal Stephenson", "isbn": "0-553-08853-X", "price": 14.95 ]
		let book3: JsonObject = [ "title": "Do Androids Dream of Electric Sheep?", "author": "Philip K. Dick", "isbn": "978-0345404473", "price": 11.89 ]
		let book4: JsonObject = [ "title": "Slaughterhouse-Five", "author": "Kurt Vonnegut", "isbn": "9780812417753", "price": 8.96 ]
		let book5: JsonObject = [ "title": "Oryx and Crake", "author": "Margaret Atwood", "isbn": "978-0385503853", "price": 13.89 ]
		let books: JsonArray = [ book1, book2, book3, book4, book5 ]
		bookList = ["books": books]
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	/// $.books[1].author
    func testSimplePathValid() {
		let nodes: [PathNode] = [.root, .property(name: "books"), .arrayItem(index: 1), .property(name:"author")]
		let compiledPart = CompiledPathPart(parts: nodes)
		runTest("simple path") {
			let result = try compiledPart.evaluate(with: bookList, registers: [bookList])
			try Expecting.string("Neal Stephenson", result: result)
		}
    }
	
	/// $.books.price.sum()
	func testCollatePropertyOnArray() {
		let nodes: [PathNode] = [.root, .property(name: "books"), .property(name:"price"), .function(function: .sum)]
		let compiledPart = CompiledPathPart(parts: nodes)
		runTest("path with collated property") {
			let result = try compiledPart.evaluate(with: bookList, registers: [bookList])
			try Expecting.number(59.68, result: result)
		}
	}
    
}
