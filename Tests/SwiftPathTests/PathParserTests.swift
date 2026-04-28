//
//  PathParserTests.swift
//  SwiftPath
//
//  Created by Steven Grosmark on 9/23/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import Testing
@testable import SwiftPath

@Suite(.serialized)
struct PathParserTests {

    @Test
    func testRoot() throws {
        let nodes = try rootNodes("$")
        #expect(nodes.isEmpty)
    }

    @Test
    func testBasicPropertyOnRoot() throws {
        let nodes = try rootNodes("$.hello")
        #expect(nodes.count == 1)
        guard case let .property(name) = nodes[0] else {
            Issue.record("expecting a property node")
            return
        }
        #expect(name == "hello")
    }

    @Test
    func testBasicArrayIndexOnRoot() throws {
        let nodes = try rootNodes("$[0]")
        #expect(nodes.count == 1)
        guard case let .arrayItem(index) = nodes[0] else {
            Issue.record("expecting an arrayItem node")
            return
        }
        #expect(index == 0)
    }

    @Test
    func testSingleQuotedPropertyOnRoot() throws {
        let nodes = try rootNodes("$['property']")
        #expect(nodes.count == 1)
        guard case let .property(name) = nodes[0] else {
            Issue.record("expecting a property node")
            return
        }
        #expect(name == "property")
    }

    @Test
    func testSingleQuotedMultiWordPropertyOnRoot() throws {
        let nodes = try rootNodes("$['property & more']")
        #expect(nodes.count == 1)
        guard case let .property(name) = nodes[0] else {
            Issue.record("expecting a property node")
            return
        }
        #expect(name == "property & more")
    }

    @Test
    func testDoubleQuotedPropertyOnRoot() throws {
        let nodes = try rootNodes("$[\"property\"]")
        #expect(nodes.count == 1)
        guard case let .property(name) = nodes[0] else {
            Issue.record("expecting a property node")
            return
        }
        #expect(name == "property")
    }

    @Test
    func testDoubleQuotedMultiWordPropertyOnRoot() throws {
        let nodes = try rootNodes("$[\"property & more\"]")
        #expect(nodes.count == 1)
        guard case let .property(name) = nodes[0] else {
            Issue.record("expecting a property node")
            return
        }
        #expect(name == "property & more")
    }

    @Test
    func testQuotedPropertiesOnRoot() throws {
        let nodes = try rootNodes("$[\"property\", 'another'=>'new-name', 'three']")
        #expect(nodes.count == 1)
        guard case let .properties(names, rename) = nodes[0] else {
            Issue.record("expecting a properties node")
            return
        }
        #expect(names == ["property", "another", "three"])
        #expect(rename == ["property", "new-name", "three"])
    }

    @Test
    func testPropertyWithDash() throws {
        let nodes = try rootNodes("$.dash-property")
        #expect(nodes.count == 1)
        guard case let .property(name) = nodes[0] else {
            Issue.record("expecting a property node")
            return
        }
        #expect(name == "dash-property")
    }

    @Test
    func testWildcard() throws {
        let nodes = try rootNodes("$.*")
        #expect(nodes.count == 1)
        guard case .values = nodes[0] else {
            Issue.record("expecting a values node")
            return
        }
    }

    @Test
    func testWildcard2() throws {
        let nodes = try rootNodes("$.coins.*[\"name\", \"ticker\"=>'symbol', 'exchange_rate_btc' => \"btc\"]")
        #expect(nodes.count == 3)
        guard case let .property(name) = nodes[0] else {
            Issue.record("expecting a property node")
            return
        }
        #expect(name == "coins")
        guard case .values = nodes[1] else {
            Issue.record("expecting a values node")
            return
        }
        guard case let .properties(names, rename) = nodes[2] else {
            Issue.record("expecting a properties node")
            return
        }
        #expect(names == ["name", "ticker", "exchange_rate_btc"])
        #expect(rename == ["name", "symbol", "btc"])
    }

    @Test
    func testArrayWildcard() throws {
        let nodes = try rootNodes("$.array[*]")
        #expect(nodes.count == 2)
        guard case let .property(name) = nodes[0] else {
            Issue.record("expecting a property node")
            return
        }
        #expect(name == "array")
        guard case .arrayValues = nodes[1] else {
            Issue.record("expecting an arrayValues node")
            return
        }
    }

    @Test
    func testArraySlice() throws {
        let tests: [(String, Int?, Int?, Int?)] = [
            ("$.array[1:3]", 1, 3, nil),
            ("$.array[:3]", nil, 3, nil),
            ("$.array[2:]", 2, nil, nil),
            ("$.array[-2:]", -2, nil, nil),
            ("$.array[1:5:2]", 1, 5, 2),
            ("$.array[::-1]", nil, nil, -1),
            ("$.array[::0]", nil, nil, 0)
        ]

        for (path, lowerBound, upperBound, step) in tests {
            let nodes = try rootNodes(path)
            #expect(nodes.count == 2)
            guard case let .property(name) = nodes[0] else {
                Issue.record("expecting a property node")
                continue
            }
            #expect(name == "array")
            guard case let .arrayRange(from, to, parsedStep) = nodes[1] else {
                Issue.record("expecting an arrayRange node")
                continue
            }
            #expect(from == lowerBound)
            #expect(to == upperBound)
            #expect(parsedStep == step)
        }
    }

    @Test
    func testArrayFilter() throws {
        let nodes = try rootNodes("$.array[?(@.id==5)]")
        #expect(nodes.count == 2)
        guard case let .property(name) = nodes[0] else {
            Issue.record("expecting a property node")
            return
        }
        #expect(name == "array")
        guard case .arrayFilter = nodes[1] else {
            Issue.record("expecting an arrayFilter node")
            return
        }
    }

    private func rootNodes(_ path: String) throws -> [PathNode] {
        let result = try #require(PathParser.parse(path: path), "expected \(path) to parse")
        guard case let .path(base, nodes) = result else {
            Issue.record("PathParser.parse returned unexpected node type")
            throw TestError(message: "unexpected node type")
        }
        guard case .root = base else {
            Issue.record("expected a root node")
            throw TestError(message: "expected root node")
        }
        return nodes
    }
}
