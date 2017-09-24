//
//  PathParserTests.swift
//  SwiftPath
//
//  Created by Steven Grosmark on 9/23/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import XCTest
@testable import SwiftPath

class PathParserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRoot() {
        let result = PathParser.parse(path: "$")
        XCTAssertNotNil(result)
        guard case let .path(base, nodes) = result! else {
            XCTFail("PathParser.parse returned unexpected node type")
            return
        }
        guard case .root = base else {
            XCTFail("expected a root node")
            return
        }
        XCTAssert(nodes.count == 0)
    }
    
    func testBasicPropertyOnRoot() {
        let result = PathParser.parse(path: "$.hello")
        XCTAssertNotNil(result)
        guard case let .path(base, nodes) = result! else {
            XCTFail("PathParser.parse returned unexpected node type")
            return
        }
        guard case .root = base else {
            XCTFail("expected a root node")
            return
        }
        XCTAssert(nodes.count == 1)
        guard case let .property(name) = nodes[0] else {
            XCTFail("expecting a property node")
            return
        }
        XCTAssertEqual(name, "hello")
    }
    
    func testBasicArrayIndexOnRoot() {
        let result = PathParser.parse(path: "$[0]")
        XCTAssertNotNil(result)
        guard case let .path(base, nodes) = result! else {
            XCTFail("PathParser.parse returned unexpected node type")
            return
        }
        guard case .root = base else {
            XCTFail("expected a root node")
            return
        }
        XCTAssert(nodes.count == 1)
        guard case let .arrayItem(index) = nodes[0] else {
            XCTFail("expecting a arrayItem node")
            return
        }
        XCTAssertEqual(index, 0)
    }
    
}
