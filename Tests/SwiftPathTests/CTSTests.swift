//
//  CTSTests.swift
//  SwiftPathTests
//
//  Runs the JSONPath Compliance Test Suite (RFC 9535) against SwiftPath.
//  Source: https://github.com/jsonpath-standard/jsonpath-compliance-test-suite
//
//  cts.json is vendored in Resources/. To refresh:
//      curl -L https://raw.githubusercontent.com/jsonpath-standard/jsonpath-compliance-test-suite/main/cts.json \
//        -o Tests/SwiftPathTests/Resources/cts.json
//

import Foundation
import Testing
@testable import SwiftPath

@Suite("CTS")
struct CTSTests {

    @Test(arguments: CTSLoader.arguments)
    func runCase(_ arg: CTSLoader.Argument) {
        let testCase = CTSLoader.cases[arg.index]
        let body: () -> Void = { CTSRunner.assert(testCase) }
        if CTSKnownFailures.names.contains(testCase.name) {
            withKnownIssue("CTS known-failure: \(testCase.name)") { body() }
        } else {
            body()
        }
    }

    /// Renders `cts-report.md` at the repo root listing every CTS case as a row.
    /// Override the destination with the `CTS_REPORT_PATH` env var (e.g. for CI artifact paths).
    @Test
    func writeReport() throws {
        let markdown = CTSReport.generate()
        try CTSReport.write(markdown)
    }
}

// MARK: - Test case model

struct CTSCase: Sendable {
    let name: String
    let selector: String
    let document: JsonValueBox?
    /// Single expected result (mutually exclusive with `results` and `invalidSelector`).
    let result: JsonArrayBox?
    /// Multiple acceptable result orderings (any-of).
    let results: [JsonArrayBox]?
    let invalidSelector: Bool
}

/// Wraps `Any` so the test case can be `Sendable`.
/// JSONSerialization output is effectively immutable Foundation values; treat it as such.
struct JsonValueBox: @unchecked Sendable {
    let value: JsonValue
}

struct JsonArrayBox: @unchecked Sendable {
    let value: JsonArray
}

// MARK: - Loader

enum CTSLoader {

    struct Argument: Sendable, CustomTestStringConvertible {
        let index: Int
        let name: String
        var testDescription: String { name }
    }

    static let cases: [CTSCase] = loadCases()

    static let arguments: [Argument] = cases.enumerated().map { Argument(index: $0.offset, name: $0.element.name) }

    private static func loadCases() -> [CTSCase] {
        guard let url = Bundle.module.url(forResource: "cts", withExtension: "json") else {
            fatalError("cts.json not found in test bundle resources")
        }
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            guard let dict = json as? [String: Any], let tests = dict["tests"] as? [[String: Any]] else {
                fatalError("cts.json malformed: expected { tests: [...] }")
            }
            return tests.map(parse(entry:))
        } catch {
            fatalError("Failed to load cts.json: \(error)")
        }
    }

    private static func parse(entry: [String: Any]) -> CTSCase {
        let name = entry["name"] as? String ?? "<unnamed>"
        let selector = entry["selector"] as? String ?? ""
        let document = (entry["document"]).map { JsonValueBox(value: $0) }
        let invalid = (entry["invalid_selector"] as? Bool) ?? false

        var result: JsonArrayBox? = nil
        if let arr = entry["result"] as? JsonArray {
            result = JsonArrayBox(value: arr)
        }
        var results: [JsonArrayBox]? = nil
        if let arrOfArr = entry["results"] as? [JsonArray] {
            results = arrOfArr.map { JsonArrayBox(value: $0) }
        }
        return CTSCase(
            name: name,
            selector: selector,
            document: document,
            result: result,
            results: results,
            invalidSelector: invalid
        )
    }
}

// MARK: - Runner

enum CTSRunner {

    enum Outcome: Sendable {
        case pass
        case fail(reason: String)

        var passed: Bool {
            if case .pass = self { return true }
            return false
        }
    }

    /// Pure evaluation — returns whether SwiftPath agrees with the CTS expectation.
    /// No `Issue.record` / `#expect` so the same logic feeds both the assertion path
    /// and the markdown report writer.
    static func evaluate(_ testCase: CTSCase) -> Outcome {
        if testCase.invalidSelector {
            if JsonPath(testCase.selector) == nil { return .pass }
            return .fail(reason: "selector should be invalid: \(testCase.selector)")
        }
        guard let path = JsonPath(testCase.selector) else {
            return .fail(reason: "selector failed to parse: \(testCase.selector)")
        }
        guard let docBox = testCase.document else {
            return .fail(reason: "test case missing document: \(testCase.name)")
        }

        let actual: JsonValue?
        do {
            actual = try path.evaluate(with: docBox.value)
        } catch {
            return .fail(reason: "evaluate threw for '\(testCase.selector)': \(error)")
        }

        let actualNodelist = normalizeToNodelist(actual)

        if let single = testCase.result {
            if jsonEqual(actualNodelist, single.value) { return .pass }
            return .fail(reason: "selector '\(testCase.selector)': expected \(single.value), got \(actualNodelist)")
        }
        if let any = testCase.results {
            let matched = any.contains { jsonEqual(actualNodelist, $0.value) }
            if matched { return .pass }
            return .fail(reason: "selector '\(testCase.selector)': result \(actualNodelist) matched none of the accepted orderings")
        }
        return .fail(reason: "test case has no expectation: \(testCase.name)")
    }

    static func assert(_ testCase: CTSCase) {
        switch evaluate(testCase) {
        case .pass:
            return
        case .fail(let reason):
            Issue.record("\(reason)")
        }
    }

    /// SwiftPath returns a single `JsonValue` (or nil) — the CTS expects a nodelist (`JsonArray`).
    /// Treat any array result as the nodelist directly; wrap scalars/objects in a singleton list.
    /// This is approximate: queries like `$` or `$.books` (where the node *is* an array) will appear
    /// to disagree, since SwiftPath erases the single-vs-multi distinction. Such cases live in
    /// `CTSKnownFailures` until SwiftPath grows a true nodelist representation.
    private static func normalizeToNodelist(_ value: JsonValue?) -> JsonArray {
        guard let value else { return [] }
        if let arr = value as? JsonArray { return arr }
        return [value]
    }
}

// MARK: - Markdown report

enum CTSReport {

    enum Status: String {
        case pass
        case fail
        case knownFailure = "known-failure"
        case unexpectedPass = "unexpected-pass"
    }

    struct Row {
        let name: String
        let selector: String
        let status: Status
    }

    static func generate() -> String {
        let known = CTSKnownFailures.names
        let rows: [Row] = CTSLoader.cases.map { testCase in
            let outcome = CTSRunner.evaluate(testCase)
            let isKnown = known.contains(testCase.name)
            let status: Status
            switch (outcome.passed, isKnown) {
            case (true, false):  status = .pass
            case (true, true):   status = .unexpectedPass
            case (false, false): status = .fail
            case (false, true):  status = .knownFailure
            }
            return Row(name: testCase.name, selector: testCase.selector, status: status)
        }
        return render(rows: rows)
    }

    static func write(_ markdown: String) throws {
        let url = outputURL()
        try markdown.write(to: url, atomically: true, encoding: .utf8)
    }

    private static func outputURL() -> URL {
        if let override = ProcessInfo.processInfo.environment["CTS_REPORT_PATH"] {
            return URL(fileURLWithPath: override)
        }
        // <repo>/Tests/SwiftPathTests/CTSTests.swift  →  <repo>/cts-report.md
        return URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("cts-report.md")
    }

    private static func render(rows: [Row]) -> String {
        var counts: [Status: Int] = [:]
        for row in rows { counts[row.status, default: 0] += 1 }
        let pass = counts[.pass, default: 0]
        let fail = counts[.fail, default: 0]
        let kf = counts[.knownFailure, default: 0]
        let up = counts[.unexpectedPass, default: 0]

        var out = ""
        out += "# JSONPath Compliance Test Suite Report\n\n"
        out += "Source: [`Tests/SwiftPathTests/Resources/cts.json`](Tests/SwiftPathTests/Resources/cts.json)\n\n"
        out += "Total: **\(rows.count)** — pass: **\(pass)**, fail: **\(fail)**, known-failure: **\(kf)**, unexpected-pass: **\(up)**\n\n"
        out += "| Name | Path | Status |\n"
        out += "|------|------|--------|\n"
        for row in rows {
            out += "| \(escapeCell(row.name)) | \(escapeCode(row.selector)) | \(row.status.rawValue) |\n"
        }
        return out
    }

    private static func escapeCell(_ s: String) -> String {
        s.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "|", with: "\\|")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
    }

    private static func escapeCode(_ s: String) -> String {
        let visible = s
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
        // Inline code spans absorb pipes in GFM tables, so no further escaping needed.
        return "`" + visible + "`"
    }
}

// MARK: - Equality (JsonValue is `Any` — JSONSerialization output)

func jsonEqual(_ a: JsonValue?, _ b: JsonValue?) -> Bool {
    switch (a, b) {
    case (nil, nil): return true
    case (nil, _), (_, nil): return false
    default: break
    }
    let lhs = a!
    let rhs = b!

    if lhs is NSNull && rhs is NSNull { return true }
    if lhs is NSNull || rhs is NSNull { return false }

    let lhsBool = isBool(lhs)
    let rhsBool = isBool(rhs)
    if lhsBool || rhsBool {
        guard lhsBool && rhsBool else { return false }
        return (lhs as? Bool) == (rhs as? Bool)
    }

    if let l = lhs as? String, let r = rhs as? String { return l == r }

    if let l = lhs as? NSNumber, let r = rhs as? NSNumber { return l == r }

    if let l = lhs as? JsonArray, let r = rhs as? JsonArray {
        guard l.count == r.count else { return false }
        return zip(l, r).allSatisfy { jsonEqual($0, $1) }
    }
    if let l = lhs as? JsonObject, let r = rhs as? JsonObject {
        guard Set(l.keys) == Set(r.keys) else { return false }
        return l.allSatisfy { jsonEqual($0.value, r[$0.key]) }
    }
    return false
}

private func isBool(_ value: Any) -> Bool {
    guard let n = value as? NSNumber else { return false }
    return CFGetTypeID(n) == CFBooleanGetTypeID()
}

// MARK: - Known failures

/// Names of CTS cases that currently do not pass. Stored as a JSON array in
/// `Resources/cts-known-failures.json` so unicode and escapes round-trip cleanly.
/// Prune entries as SwiftPath catches up to RFC 9535 — each one is a `withKnownIssue`,
/// so a case unexpectedly passing surfaces as a regression in the test report.
enum CTSKnownFailures {
    static let names: Set<String> = load()

    private static func load() -> Set<String> {
        guard let url = Bundle.module.url(forResource: "cts-known-failures", withExtension: "json") else {
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let arr = try JSONSerialization.jsonObject(with: data) as? [String] ?? []
            return Set(arr)
        } catch {
            return []
        }
    }
}
