//
//  ConcurrencyTests.swift
//  SwiftPath
//
//  Created by Steven Grosmark on 4/28/26.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//
//  Stress-tests the library from multiple background threads to surface
//  any data races. Run with `swift test --sanitize=thread` for full coverage.
//

import XCTest
@testable import SwiftPath

final class ConcurrencyTests: XCTestCase {

    private let booksJson = """
    {
        "books": [
            {"id": 1, "title": "Ready Player One", "author": "Ernest Cline", "isbn": "978-0307887436", "price": 9.99, "available": true},
            {"id": 2, "title": "Snow Crash", "author": "Neal Stephenson", "isbn": "0-553-08853-X", "price": 14.95, "available": false},
            {"id": 3, "title": "Do Androids Dream of Electric Sheep?", "author": "Philip K. Dick", "isbn": "978-0345404473", "price": 11.89, "available": true},
            {"id": 4, "title": "Slaughterhouse-Five", "author": "Kurt Vonnegut", "isbn": "9780812417753", "price": 8.96, "available": false},
            {"id": 5, "title": "Oryx and Crake", "author": "Margaret Atwood", "isbn": null, "price": 13.89, "available": true}
        ]
    }
    """

    private let pathStrings: [String] = [
        "$.books[0].title",
        "$.books[*].author",
        "$.books[1:3]",
        "$.books[?(@.available == true)]",
        "$.books[?(@.price < 12.0)]",
        "$.books[?(@.id == 1 || @.id == 2)]",
        "$.books[?(!(@.available == true))]",
        "$.books[?(@.isbn == null)]",
        "$.books[::-1]",
        "$.books[-2:]",
        "$.books['title', 'author']",
        "$.books[?(@.author == 'Ernest Cline')]",
    ]

    private static let iterations = 5_000

    /// Many threads concurrently parse JSONPath strings.
    /// Exercises PathParser's static parser combinators (Parser<T>: @unchecked Sendable).
    func testParallelPathParsing() {
        let strings = pathStrings
        DispatchQueue.concurrentPerform(iterations: Self.iterations) { i in
            let str = strings[i % strings.count]
            XCTAssertNotNil(JsonPath(str), "failed to parse \(str)")
        }
    }

    /// One shared JsonPath evaluated against the same JSON from many threads.
    /// Exercises that the compiled PathNode tree can be safely read concurrently.
    func testParallelEvaluationSharedPath() {
        guard let path = JsonPath("$.books[?(@.available == true)]") else {
            return XCTFail("path failed to parse")
        }
        let json = booksJson
        DispatchQueue.concurrentPerform(iterations: Self.iterations) { _ in
            do {
                let result = try path.evaluate(with: json) as? JsonArray
                XCTAssertEqual(result?.count, 3)
            } catch {
                XCTFail("evaluate failed: \(error)")
            }
        }
    }

    /// Multiple distinct JsonPaths evaluated concurrently against the same JSON.
    func testParallelEvaluationDifferentPaths() {
        let paths: [JsonPath] = pathStrings.compactMap(JsonPath.init)
        XCTAssertEqual(paths.count, pathStrings.count)
        let json = booksJson
        DispatchQueue.concurrentPerform(iterations: Self.iterations) { i in
            let path = paths[i % paths.count]
            do {
                _ = try path.evaluate(with: json)
            } catch {
                XCTFail("evaluate failed: \(error)")
            }
        }
    }

    /// Filter expressions exercised heavily across threads.
    /// Exercises FilterExpression: @unchecked Sendable (the case carrying JsonValue = Any).
    func testParallelFilterEvaluation() {
        let filterPaths: [JsonPath] = [
            "$.books[?(@.id == 1 || @.id == 2 || @.id == 3)]",
            "$.books[?(@.available == true && @.price < 12.0)]",
            "$.books[?(!(@.isbn == null))]",
            "$.books[?(@.price > 9.0 && @.price < 14.0)]",
            "$.books[?(@.author == 'Ernest Cline')]",
            "$.books[?(@.title == 'Snow Crash')]",
        ].compactMap(JsonPath.init)
        XCTAssertEqual(filterPaths.count, 6)
        let json = booksJson
        DispatchQueue.concurrentPerform(iterations: Self.iterations) { i in
            let path = filterPaths[i % filterPaths.count]
            do {
                _ = try path.evaluate(with: json)
            } catch {
                XCTFail("evaluate failed: \(error)")
            }
        }
    }

    /// Mixed workload: half the iterations parse, half evaluate.
    func testParallelMixedParseAndEvaluate() {
        guard let sharedPath = JsonPath("$.books[?(@.id == 5)]") else {
            return XCTFail("path failed to parse")
        }
        let strings = pathStrings
        let json = booksJson
        DispatchQueue.concurrentPerform(iterations: Self.iterations) { i in
            if i.isMultiple(of: 2) {
                let str = strings[i % strings.count]
                XCTAssertNotNil(JsonPath(str), "failed to parse \(str)")
            } else {
                do {
                    let result = try sharedPath.evaluate(with: json) as? JsonArray
                    XCTAssertEqual(result?.count, 1)
                } catch {
                    XCTFail("evaluate failed: \(error)")
                }
            }
        }
    }

    /// Different threading model — global queue + DispatchGroup, vs concurrentPerform.
    func testParallelEvaluationViaGlobalQueue() {
        guard let path = JsonPath("$.books[*].title") else {
            return XCTFail("path failed to parse")
        }
        let json = booksJson
        let group = DispatchGroup()
        let iterations = 1_000
        for _ in 0..<iterations {
            group.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                defer { group.leave() }
                do {
                    let result = try path.evaluate(with: json) as? JsonArray
                    XCTAssertEqual(result?.count, 5)
                } catch {
                    XCTFail("evaluate failed: \(error)")
                }
            }
        }
        XCTAssertEqual(group.wait(timeout: .now() + 30), .success)
    }

    /// Exercise array-slice paths in parallel — the most recent feature on this branch.
    func testParallelArraySliceEvaluation() {
        let slicePaths: [(String, Int)] = [
            ("$.books[1:3]", 2),
            ("$.books[:3]", 3),
            ("$.books[2:]", 3),
            ("$.books[-2:]", 2),
            ("$.books[1:5:2]", 2),
            ("$.books[::-1]", 5),
            ("$.books[-99:99]", 5),
        ]
        let compiled: [(JsonPath, Int)] = slicePaths.compactMap { string, count in
            guard let path = JsonPath(string) else { return nil }
            return (path, count)
        }
        XCTAssertEqual(compiled.count, slicePaths.count)
        let json = booksJson
        DispatchQueue.concurrentPerform(iterations: Self.iterations) { i in
            let (path, expectedCount) = compiled[i % compiled.count]
            do {
                let result = try path.evaluate(with: json) as? JsonArray
                XCTAssertEqual(result?.count, expectedCount)
            } catch {
                XCTFail("evaluate failed: \(error)")
            }
        }
    }

    // MARK: - Swift Concurrency variants

    /// Parse paths concurrently via a structured TaskGroup.
    func testParallelPathParsingViaTaskGroup() async {
        let strings = pathStrings
        await withTaskGroup(of: Bool.self) { group in
            for i in 0..<Self.iterations {
                let str = strings[i % strings.count]
                group.addTask {
                    JsonPath(str) != nil
                }
            }
            for await parsed in group {
                XCTAssertTrue(parsed)
            }
        }
    }

    /// One shared JsonPath evaluated from many child tasks.
    func testParallelEvaluationViaTaskGroup() async {
        guard let path = JsonPath("$.books[?(@.available == true)]") else {
            return XCTFail("path failed to parse")
        }
        let json = booksJson
        await withTaskGroup(of: Int?.self) { group in
            for _ in 0..<Self.iterations {
                group.addTask {
                    let result = try? path.evaluate(with: json) as? JsonArray
                    return result?.count
                }
            }
            for await count in group {
                XCTAssertEqual(count, 3)
            }
        }
    }

    /// Filter expressions exercised across child tasks — JsonValue=Any in associated values.
    func testParallelFilterEvaluationViaTaskGroup() async {
        let filterPaths: [JsonPath] = [
            "$.books[?(@.id == 1 || @.id == 2 || @.id == 3)]",
            "$.books[?(@.available == true && @.price < 12.0)]",
            "$.books[?(!(@.isbn == null))]",
            "$.books[?(@.price > 9.0 && @.price < 14.0)]",
            "$.books[?(@.author == 'Ernest Cline')]",
            "$.books[?(@.title == 'Snow Crash')]",
        ].compactMap(JsonPath.init)
        XCTAssertEqual(filterPaths.count, 6)
        let json = booksJson
        await withTaskGroup(of: Bool.self) { group in
            for i in 0..<Self.iterations {
                let path = filterPaths[i % filterPaths.count]
                group.addTask {
                    (try? path.evaluate(with: json)) != nil
                }
            }
            for await ok in group {
                XCTAssertTrue(ok)
            }
        }
    }

    /// Force off-actor execution via Task.detached — closer to the GCD global-queue model.
    func testParallelEvaluationViaDetachedTasks() async {
        guard let path = JsonPath("$.books[*].title") else {
            return XCTFail("path failed to parse")
        }
        let json = booksJson
        await withTaskGroup(of: Int?.self) { group in
            for _ in 0..<1_000 {
                group.addTask {
                    await Task.detached(priority: .userInitiated) {
                        let result = try? path.evaluate(with: json) as? JsonArray
                        return result?.count
                    }.value
                }
            }
            for await count in group {
                XCTAssertEqual(count, 5)
            }
        }
    }

    /// Fixed parallelism via async let — each iteration evaluates four paths concurrently.
    func testAsyncLetParallelEvaluation() async {
        guard let pathA = JsonPath("$.books[?(@.id == 1)]"),
              let pathB = JsonPath("$.books[?(@.id == 2)]"),
              let pathC = JsonPath("$.books[?(@.id == 3)]"),
              let pathD = JsonPath("$.books[?(@.id == 4)]") else {
            return XCTFail("paths failed to parse")
        }
        let json = booksJson

        await withTaskGroup(of: [Int].self) { group in
            for _ in 0..<500 {
                group.addTask {
                    async let a = (try? pathA.evaluate(with: json) as? JsonArray)?.count ?? -1
                    async let b = (try? pathB.evaluate(with: json) as? JsonArray)?.count ?? -1
                    async let c = (try? pathC.evaluate(with: json) as? JsonArray)?.count ?? -1
                    async let d = (try? pathD.evaluate(with: json) as? JsonArray)?.count ?? -1
                    return await [a, b, c, d]
                }
            }
            for await counts in group {
                XCTAssertEqual(counts, [1, 1, 1, 1])
            }
        }
    }

    /// Mixed parse + evaluate via TaskGroup.
    func testParallelMixedParseAndEvaluateViaTaskGroup() async {
        guard let sharedPath = JsonPath("$.books[?(@.id == 5)]") else {
            return XCTFail("path failed to parse")
        }
        let strings = pathStrings
        let json = booksJson
        await withTaskGroup(of: Bool.self) { group in
            for i in 0..<Self.iterations {
                if i.isMultiple(of: 2) {
                    let str = strings[i % strings.count]
                    group.addTask {
                        JsonPath(str) != nil
                    }
                } else {
                    group.addTask {
                        let result = try? sharedPath.evaluate(with: json) as? JsonArray
                        return result?.count == 1
                    }
                }
            }
            for await ok in group {
                XCTAssertTrue(ok)
            }
        }
    }
}
