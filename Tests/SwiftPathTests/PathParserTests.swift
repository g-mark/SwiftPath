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
    
    func testSingleQuotedPropertyOnRoot() {
        let result = PathParser.parse(path: "$['property']")
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
        XCTAssertEqual(name, "property")
    }
    
    func testSingleQuotedMultiWordPropertyOnRoot() {
        let result = PathParser.parse(path: "$['property & more']")
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
        XCTAssertEqual(name, "property & more")
    }
    
    func testDoubleQuotedPropertyOnRoot() {
        let result = PathParser.parse(path: "$[\"property\"]")
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
        XCTAssertEqual(name, "property")
    }
    
    func testDoubleQuotedMultiWordPropertyOnRoot() {
        let result = PathParser.parse(path: "$[\"property & more\"]")
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
        XCTAssertEqual(name, "property & more")
    }
    
    func testQuotedPropertiesOnRoot() {
        let result = PathParser.parse(path: "$[\"property\", 'another'=>'new-name', 'three']")
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
        guard case let .properties(names, rename) = nodes[0] else {
            XCTFail("expecting a properties node")
            return
        }
        XCTAssertEqual(names, ["property", "another", "three"])
        XCTAssertEqual(rename, ["property", "new-name", "three"])
    }
    
    func testWildcard() {
        let result = PathParser.parse(path: "$.*")
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
        guard case .values = nodes[0] else {
            XCTFail("expecting a values node")
            return
        }
    }
    
    func testWildcard2() {
        let result = PathParser.parse(path: "$.coins.*[\"name\", \"ticker\"=>'symbol', 'exchange_rate_btc' => \"btc\"]")
        XCTAssertNotNil(result)
        guard case let .path(base, nodes) = result! else {
            XCTFail("PathParser.parse returned unexpected node type")
            return
        }
        guard case .root = base else {
            XCTFail("expected a root node")
            return
        }
        XCTAssert(nodes.count == 3)
        guard case let .property(name) = nodes[0] else {
            XCTFail("expecting a property node")
            return
        }
        XCTAssertEqual(name, "coins")
        guard case .values = nodes[1] else {
            XCTFail("expecting a values node")
            return
        }
        guard case let .properties(names, rename) = nodes[2] else {
            XCTFail("expecting a properties node")
            return
        }
        XCTAssertEqual(names, ["name", "ticker", "exchange_rate_btc"])
        XCTAssertEqual(rename, ["name", "symbol", "btc"])
    }
    
}
