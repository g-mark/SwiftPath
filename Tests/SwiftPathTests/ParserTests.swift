//
//  ParserTests.swift
//  SwiftPath
//
//  Created by Steven Grosmark on 9/22/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import XCTest
@testable import SwiftPath

class ParserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /// sime parsing of a literal
    func testLiteral() {
        let helloParser = literal(string: "hello")
        let tup = helloParser.run("hello")
        XCTAssertNotNil(tup)
        let (result, remains) = tup!
        XCTAssertEqual(result, "hello")
        XCTAssertEqual(remains, "")
    }
    
    func testLiteralRemnants() {
        let helloParser = literal(string: "hello")
        let tup = helloParser.run("helloooo")
        XCTAssertNotNil(tup)
        let (result, remains) = tup!
        XCTAssertEqual(result, "hello")
        XCTAssertNotEqual(remains, "")
    }
    
    func testLiteralFail() {
        let helloParser = literal(string: "hello")
        var tup = helloParser.run("goodbye")
        XCTAssertNil(tup)
        
        tup = helloParser.run("")
        XCTAssertNil(tup)
        
        tup = helloParser.run("well, hello")
        XCTAssertNil(tup)
    }
    
    /// simple RegEx pattern
    func testPattern() {
        let alphaParser = pattern(string: "[a-zA-Z]+")
        
        var tup = alphaParser.run("hello")
        XCTAssertNotNil(tup)
        var (result, remains) = tup!
        XCTAssertEqual(result, "hello")
        XCTAssertEqual(remains, "")
        
        tup = alphaParser.run("Othello123")
        XCTAssertNotNil(tup)
        (result, remains) = tup!
        XCTAssertEqual(result, "Othello")
        XCTAssertEqual(remains, "123")
    }
    
    func testPatternFail() {
        let alphaParser = pattern(string: "[a-zA-Z]+")
        
        var tup = alphaParser.run("123")
        XCTAssertNil(tup)
        
        tup = alphaParser.run("")
        XCTAssertNil(tup)
        
        tup = alphaParser.run("!$@#%^%$")
        XCTAssertNil(tup)
        
        tup = alphaParser.run("汉语/漢語")
        XCTAssertNil(tup)
    }
    
    /// one parser folled by another
    func testSequence() {
        let helloParser = literal(string: "hello")
        let worldParser = literal(string: "world")
        let space = pattern(string: "[\\s\\t\\r\\n]+")
        let helloWorldParser = helloParser.followed(by: [space, worldParser])
        
        let tup = helloWorldParser.run("hello world")
        XCTAssertNotNil(tup)
        let (result, remains) = tup!
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result.joined(), "hello world")
        XCTAssertEqual(remains, "")
    }
    
    /// one or another parser
    func testOr() {
        let helloParser = literal(string: "hello")
        let hiParser = literal(string: "hi")
        let holaParser = literal(string: "¡Hola")
        let moshiParser = literal(string: "もしもし")
        let greeting = helloParser.or(hiParser).or(holaParser).or(moshiParser)
        
        var tup = greeting.run("hello")
        XCTAssertNotNil(tup)
        var (result, remains) = tup!
        XCTAssertEqual(result, "hello")
        XCTAssertEqual(remains, "")
        
        tup = greeting.run("hi")
        XCTAssertNotNil(tup)
        (result, remains) = tup!
        XCTAssertEqual(result, "hi")
        XCTAssertEqual(remains, "")
        
        tup = greeting.run("¡Hola")
        XCTAssertNotNil(tup)
        (result, remains) = tup!
        XCTAssertEqual(result, "¡Hola")
        XCTAssertEqual(remains, "")
        
        tup = greeting.run("もしもし")
        XCTAssertNotNil(tup)
        (result, remains) = tup!
        XCTAssertEqual(result, "もしもし")
        XCTAssertEqual(remains, "")
    }
    
    func testRepeated() {
        
    }
}

