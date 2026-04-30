//
//  ParserTests.swift
//  SwiftPath
//
//  Created by Steven Grosmark on 9/22/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import Dispatch
import Testing
@testable import SwiftPath

@Suite(.serialized)
struct ParserTests {
    
    /// sime parsing of a literal
    @Test
    func testLiteral() throws {
        let helloParser = literal(string: "hello")
        let (result, remains) = try #require(helloParser.run("hello"))
        #expect(result == "hello")
        #expect(remains == "")
    }
    
    @Test
    func testLiteralRemnants() throws {
        let helloParser = literal(string: "hello")
        let (result, remains) = try #require(helloParser.run("helloooo"))
        #expect(result == "hello")
        #expect(remains != "")
    }
    
    @Test
    func testLiteralFail() {
        let helloParser = literal(string: "hello")
        var tup = helloParser.run("goodbye")
        #expect(tup == nil)
        
        tup = helloParser.run("")
        #expect(tup == nil)
        
        tup = helloParser.run("well, hello")
        #expect(tup == nil)
    }
    
    /// simple RegEx pattern
    @Test
    func testPattern() throws {
        let alphaParser = pattern(string: "[a-zA-Z]+")
        
        var (result, remains) = try #require(alphaParser.run("hello"))
        #expect(result == "hello")
        #expect(remains == "")
        
        (result, remains) = try #require(alphaParser.run("Othello123"))
        #expect(result == "Othello")
        #expect(remains == "123")
    }
    
    @Test
    func testPatternFail() {
        let alphaParser = pattern(string: "[a-zA-Z]+")
        
        var tup = alphaParser.run("123")
        #expect(tup == nil)
        
        tup = alphaParser.run("")
        #expect(tup == nil)
        
        tup = alphaParser.run("!$@#%^%$")
        #expect(tup == nil)
        
        tup = alphaParser.run("汉语/漢語")
        #expect(tup == nil)
    }

    @Test
    func testPatternDoesNotMatchEmptyAtAdvancedScannerPosition() {
        let bracketedNumberParser = literal(string: "[").followed(by: pattern(string: "-?[0-9]+"))
        #expect(bracketedNumberParser.run("[*]") == nil)
    }
    
    /// one parser followed by another
    @Test
    func testSequence() throws {
        let helloParser = literal(string: "hello")
        let worldParser = literal(string: "world")
        let space = pattern(string: "[\\s\\t\\r\\n]+")
        let helloWorldParser = helloParser.followed(by: [space, worldParser])
        
        let (result, remains) = try #require(helloWorldParser.run("hello world"))
        #expect(result.count == 3)
        #expect(result.joined() == "hello world")
        #expect(remains == "")
    }
    
    /// one or another parser
    @Test
    func testOr() throws {
        let helloParser = literal(string: "hello")
        let hiParser = literal(string: "hi")
        let holaParser = literal(string: "¡Hola")
        let moshiParser = literal(string: "もしもし")
        let greeting = helloParser.or(hiParser).or(holaParser).or(moshiParser)
        
        var (result, remains) = try #require(greeting.run("hello"))
        #expect(result == "hello")
        #expect(remains == "")
        
        (result, remains) = try #require(greeting.run("hi"))
        #expect(result == "hi")
        #expect(remains == "")
        
        (result, remains) = try #require(greeting.run("¡Hola"))
        #expect(result == "¡Hola")
        #expect(remains == "")
        
        (result, remains) = try #require(greeting.run("もしもし"))
        #expect(result == "もしもし")
        #expect(remains == "")
    }

    @Test
    func testAttemptRollsBackConsumedInputOnFailure() throws {
        let abParser = literal(string: "a").followed(by: literal(string: "b")).attempt()
        let aParser = literal(string: "a").map { [$0] }
        let parser = abParser.or(aParser)

        let (result, remains) = try #require(parser.run("ac"))
        #expect(result == ["a"])
        #expect(remains == "c")
    }

    @Test
    func testTokenParsersConsumeSurroundingWhitespace() throws {
        let equalsParser = token(string: "==")
        let (result, remains) = try #require(equalsParser.run("  ==  rest"))
        #expect(result == "==")
        #expect(remains == "rest")

        let numberParser = tokenPattern(string: "-?[0-9]+")
        let (number, numberRemains) = try #require(numberParser.run("  -12  rest"))
        #expect(number == "-12")
        #expect(numberRemains == "rest")
    }

    @Test
    func testChainLeftParsesLeftAssociativeOperators() throws {
        let numberParser = tokenPattern(string: "[0-9]+").map { Int($0)! }
        let plusParser = token(string: "+").map { _ in { (lhs: Int, rhs: Int) in lhs + rhs } }
        let parser = numberParser.chainLeft(operator: plusParser)

        let (result, remains) = try #require(parser.run("1 + 2 + 3 rest"))
        #expect(result == 6)
        #expect(remains == "rest")
    }

    @Test
    func testLazyDefersParserConstruction() throws {
        let parser = Parser<String>.lazy { literal(string: "later") }
        let (result, remains) = try #require(parser.run("later remains"))
        #expect(result == "later")
        #expect(remains == " remains")
    }

    @Test
    func testOptionalParserReturnsNilWithoutConsumingInput() throws {
        let parser = literal(string: "hello").optional()

        let missing = try #require(parser.run("world"))
        #expect(missing.0 == nil)
        #expect(missing.1 == "world")

        let present = try #require(parser.run("hello world"))
        #expect(present.0 == "hello")
        #expect(present.1 == " world")
    }

    @Test
    func testRepeatedParserDoesNotLoopForeverWhenParserSucceedsWithoutConsumingInput() {
        let emptyParser = Parser<String>(parse: { scanner in ("", scanner) })
        let parser = emptyParser.repeated()
        let finished = DispatchSemaphore(value: 0)

        DispatchQueue.global(qos: .userInitiated).async {
            _ = parser.run("input")
            finished.signal()
        }

        #expect(
            finished.wait(timeout: .now() + .milliseconds(200)) == .success,
            "repeated() must fail or stop when its parser succeeds without advancing the scanner"
        )
    }
    
    @Test
    func testRepeated() {
        
    }
}
