//
//  PathScanner.swift
//  SwiftPath
//
//  Created by Steven Grosmark on 8/25/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import Foundation

internal struct PathParser {
	
    // MARK: entry point to parse a path
    internal static func parse(path: String) -> PathNode? {
        guard let (node, remnants) = Path.run(path) else { return nil }
        guard remnants.count == 0 else { return nil }
        return node
    }
    
    // MARK: path node parsers

    /// root node, e.g. `$`
    private static let Root = literal(string: "$").map { _ in PathNode.root }
    /// current node, e.g. `@`
    private static let Current = literal(string: "@").map { _ in PathNode.current }
    /// root or current node, e.g. `$` or `@`
    private static let Node = Root.or(Current)
    
    /// wildcard for object values or array items, e.g. `.*` or `[*]`
    private static let Wildcard = literal(string: "*").map { _ in PathNode.arrayValues }
    
    /// dot separator before a property name, e.g. `.title`
    private static let Dot = literal(string: ".")
    /// property name used in dot notation, e.g. `title` in `.title`
    private static let DotPropertyName = pattern(string: "(?:[a-zA-Z_][a-zA-Z0-9_$-]*)|\\*")
    /// dot-property selector, e.g. `.title` or `.*`
    private static let DotProperty = Dot.followed(by: DotPropertyName).map { list -> PathNode in
        if list[1] == "*" { return PathNode.values }
        return PathNode.property(name: list[1])
    }
        
    /// double quote delimiter, e.g. `"` in `["title"]`
    private static let Quote = literal(string: "\"")
    /// single quote delimiter, e.g. `'` in `['title']`
    private static let SingleQuote = literal(string: "'")
    /// comma delimiter with optional surrounding whitespace, e.g. `, ` in `['a', 'b']`
    private static let Comma = pattern(string: "\\s*,\\s*")
    
    /// contents inside a quoted property name, e.g. `title` in `['title']`
    private static let QuotedPropertyNameContent = pattern(string: "[^\t\r\n\"\']+")
    /// double-quoted property name, e.g. `"title"`
    private static let DoubleQuotedPropertyName = Quote.followed(by: [QuotedPropertyNameContent, Quote]).map { $0[1] }
    /// single-quoted property name, e.g. `'title'`
    private static let SingleQuotedPropertyName = SingleQuote.followed(by: [QuotedPropertyNameContent, SingleQuote]).map { $0[1] }
    
    /// quoted property name, e.g. `"title"` or `'title'`
    private static let QuotedPropertyName = DoubleQuotedPropertyName.or(SingleQuotedPropertyName)

    /// opening bracket in filter paths, e.g. `[` in `@['id']`
    private static let FilterOpenBracket = pattern(string: "\\[\\s*").map { _ in PathNode.noop }
    /// closing bracket in filter paths, e.g. `]` in `@['id']`
    private static let FilterCloseBracket = pattern(string: "\\s*\\]").map { _ in PathNode.noop }
    /// quoted bracket property in a filter path, e.g. `['id']` in `@['id']`
    private static let FilterBracketProperty = FilterOpenBracket.followed(by: [
        QuotedPropertyName.map { PathNode.property(name: $0) },
        FilterCloseBracket
    ]).map { $0[1] }
    /// filter path selector, e.g. `.id` or `['id']`
    private static let FilterPathSpecifier = DotProperty.or(FilterBracketProperty)
    /// zero or more filter path selectors, e.g. `.book['id']`
    private static let FilterPathSpecifiers = FilterPathSpecifier.zeroOrMore().map { PathNode.nodes(nodes: $0) }
    /// root or current filter path, e.g. `@.id` or `$['target']`
    private static let FilterPath = Node.followed(by: FilterPathSpecifiers).map { result -> PathNode? in
        guard case let .nodes(nodes) = result[1] else { return nil }
        return PathNode.path(base: result[0], nodes: nodes)
    }
    
    /// property selection without a rename, e.g. `'title'`
    private static let PropertySelection = QuotedPropertyName.map { name -> (String, String) in
        return (name, name)
    }
    
    /// rename operator for property selection, e.g. `=>` in `'value'=>'id'`
    private static let RenameArrow = pattern(string: "\\s*=>\\s*")
    /// rename target for property selection, e.g. `'id'` in `'value'=>'id'`
    private static let RenameTarget = RenameArrow.followed(by: QuotedPropertyName).map { str -> (String, String) in return (str[1], str[1]) }
    
    /// property selection with an optional rename, e.g. `'value'=>'id'`
    private static let RenameablePropertySelection = PropertySelection.followed(by: RenameTarget, required: false).map { list -> (String, String) in
        guard list.count > 1 else { return list[0] }
        return (list[0].0, list[1].0)
    }
    
    /// comma-separated property selections, e.g. `['name', 'value'=>'id']`
    private static let PropertySelectionList = RenameablePropertySelection.repeated(delimiter: Comma).map { list -> PathNode in
        guard list.count > 1 else { return PathNode.property(name: list[0].0) }
        let (names, rename) = list.reduce(into: ([String](), [String]())) {
            $0.0.append($1.0)
            $0.1.append($1.1)
        }
        return PathNode.properties(names: names, rename: rename)
    }
    
    /// array index value, e.g. `0` in `[0]`
    private static let IndexValue = pattern(string: "-?[0-9]+").map { Int($0) }
    /// comma-separated array index values, e.g. `0, 2` in `[0, 2]`
    private static let IndexValueList = IndexValue.repeated(delimiter: Comma).map { list -> PathNode in
        let flat = list.compactMap { $0 }
        return flat.count == 1 ? PathNode.arrayItem(index: flat[0]) : PathNode.arrayItems(indices: flat)
    }

    /// array slice selector, e.g. `1:3`, `:3`, `2:`, `-2:`, or `1:5:2`
    private static let ArraySliceSpecifier = Parser<PathNode>(parse: { scanner in
        guard let match = scanner.mustMatch(pattern: "\\s*-?[0-9]*\\s*:\\s*-?[0-9]*\\s*(?::\\s*-?[0-9]+\\s*)?") else { return nil }
        let parts = match.components(separatedBy: ":")
        guard parts.count == 2 || parts.count == 3 else { return nil }
        let step = parts.count == 3 ? optionalInt(parts[2]) : nil
        return (PathNode.arrayRange(from: optionalInt(parts[0]), to: optionalInt(parts[1]), step: step), scanner)
    })

    /// array filter selector, e.g. `[?(@.id == 5)]`
    private static let ArrayFilterSpecifier = Parser<PathNode>(parse: { scanner in
        guard let (_, filterScanner) = token(string: "?").parse(scanner) else { return nil }
        guard let (expression, expressionScanner) = FilterExpressionParser.parse(filterScanner) else { return nil }
        return (PathNode.arrayFilter(filter: ArrayFilter(expression: expression)), expressionScanner)
    })

    /// filter expression parser entry point, e.g. `@.id == 5`
    private static var FilterExpressionParser: Parser<FilterExpression> {
        return Parser<FilterExpression>.lazy { FilterOrExpression }
    }

    /// filter logical-or expression, e.g. `@.id == 1 || @.id == 2`
    private static var FilterOrExpression: Parser<FilterExpression> {
        return FilterAndExpression.chainLeft(operator: FilterOrOperator)
    }

    /// filter logical-and expression, e.g. `@.enabled && @.price < 10`
    private static var FilterAndExpression: Parser<FilterExpression> {
        return FilterNotExpression.chainLeft(operator: FilterAndOperator)
    }

    /// filter logical-not expression, e.g. `!(@.enabled)`
    private static var FilterNotExpression: Parser<FilterExpression> {
        return Parser<FilterExpression>(parse: { scanner in
            if let (_, notScanner) = token(string: "!").parse(scanner) {
                guard let (expression, expressionScanner) = Self.FilterNotExpression.parse(notScanner) else { return nil }
                return (.not(expression), expressionScanner)
            }
            return FilterPrimaryExpression.parse(scanner)
        })
    }

    /// filter primary expression, e.g. `@.id == 5`, `@.id`, or `(@.id == 5)`
    private static var FilterPrimaryExpression: Parser<FilterExpression> {
        return FilterComparisonExpression.attempt().or(FilterExistenceExpression).or(FilterParenthesizedExpression)
    }

    /// filter comparison expression, e.g. `@.id == 5`
    private static var FilterComparisonExpression: Parser<FilterExpression> {
        return Parser<FilterExpression>(parse: { scanner in
            guard let (path, pathScanner) = parseFilterPath(scanner) else { return nil }
            guard let comparisonOperator = parseFilterComparisonOperator(pathScanner) else { return nil }
            guard let expectedValue = parseFilterValue(pathScanner) else { return nil }
            return (.comparison(path, comparisonOperator, expectedValue), pathScanner)
        })
    }

    /// filter existence expression, e.g. `@.isbn`
    private static var FilterExistenceExpression: Parser<FilterExpression> {
        return Parser<FilterExpression>(parse: { scanner in
            guard let (path, pathScanner) = parseFilterPath(scanner) else { return nil }
            return (.exists(path), pathScanner)
        })
    }

    /// parenthesized filter expression, e.g. `(@.id == 5)`
    private static var FilterParenthesizedExpression: Parser<FilterExpression> {
        return Parser<FilterExpression>(parse: { scanner in
            guard let (_, openScanner) = token(string: "(").parse(scanner) else { return nil }
            guard let (expression, expressionScanner) = FilterExpressionParser.parse(openScanner) else { return nil }
            guard let (_, closeScanner) = token(string: ")").parse(expressionScanner) else { return nil }
            return (expression, closeScanner)
        })
    }

    /// filter logical-and operator, e.g. `&&`
    private static var FilterAndOperator: Parser<(FilterExpression, FilterExpression) -> FilterExpression> {
        return token(string: "&&").map { _ in
            { (lhs: FilterExpression, rhs: FilterExpression) in .and(lhs, rhs) }
        }
    }

    /// filter logical-or operator, e.g. `||`
    private static var FilterOrOperator: Parser<(FilterExpression, FilterExpression) -> FilterExpression> {
        return token(string: "||").map { _ in
            { (lhs: FilterExpression, rhs: FilterExpression) in .or(lhs, rhs) }
        }
    }

    /// parse a filter path into an evaluatable path part, e.g. `@.id`
    private static func parseFilterPath(_ scanner: PathScanner) -> (JsonPathPart, PathScanner)? {
        guard let (parsedPath, pathScanner) = FilterPath.parse(scanner), let pathNode = parsedPath else { return nil }
        guard case let .path(base, nodes) = pathNode else { return nil }
        return (JsonPathPart(parts: [base] + nodes), pathScanner)
    }

    /// bracket selector contents, e.g. `'id'`, `0`, `1:3`, `*`, or `?(@.id == 5)`
    private static let BracketSpecifier = PropertySelectionList.or(ArraySliceSpecifier).or(IndexValueList).or(Wildcard).or(ArrayFilterSpecifier)
    
    
    /// opening bracket in a bracket selector, e.g. `[` in `[0]`
    private static let OpenBracket = pattern(string: "\\[\\s*").map { str -> PathNode in PathNode.noop }
    /// closing bracket in a bracket selector, e.g. `]` in `[0]`
    private static let CloseBracket = pattern(string: "\\s*\\]").map { str -> PathNode in PathNode.noop }
    /// bracket selector, e.g. `[0]`, `['id']`, or `[?(@.id == 5)]`
    private static let BracketSelector = OpenBracket.followed(by: [BracketSpecifier, CloseBracket]).map { $0[1] }
    
    /// dot-property or bracket selector, e.g. `.id` or `[0]`
    private static let Specifier = DotProperty.or(BracketSelector)
    
    /// zero or more path selectors, e.g. `.books[0].title`
    private static let Specifiers = Specifier.zeroOrMore().map { PathNode.nodes(nodes: $0) }
    
    /// reference node at the start of a path, e.g. `$` in `$.books`
    private static let ReferenceNode = Root.or(Current)
    /// full root or current path, e.g. `$.books[0].title`
    private static let Path = ReferenceNode.followed(by: Specifiers).map { result -> PathNode? in
        guard case let .nodes(nodes) = result[1] else { return nil }
        return PathNode.path(base: result[0], nodes: nodes)
    }
    
    /*
    Node.run("$")
    Node.run("@")
    
    DotProperty.run(".hello")
    DotProperty.run(". fail")
    
    RenameablePropertySelection.run("\"123ghj\"")
    PropertySelectionList.run("\"123\", \"abc\", \"himom!\"")
    
    IndexValue.run("")
    IndexValue.run("123")
    IndexValue.run("-37")
    IndexValue.run("-1-1")
    IndexValue.run("333-4")
    IndexValue.run("85-")
    
    IndexValueList.run("42")
    IndexValueList.run("1,12,      56     ,9")
    
    BracketSpecifier.run("\"123ghj\"")
    BracketSpecifier.run("\"123\", \"abc\", \"himom!\"")
    BracketSpecifier.run("42")
    BracketSpecifier.run("1,12,      56     ,9")
    
    BracketSelector.run("[1,2,3]")
    BracketSelector.run("[0]")
    BracketSelector.run("[-1]")
    BracketSelector.run("[]")
    BracketSelector.run("[\"hello\"]")
    BracketSelector.run("[\"hello\", \"mother\"]")
    BracketSelector.run("[\"hello\", 3]")
    
    Specifier.run(".yoyoma")
    Specifier.run("[\"yoyoma\"]")
    Specifier.run("[0]")
    
    Path.run("$[1].hello")
     */
}

/// parse a filter comparison operator, e.g. `==` or `<=`
private func parseFilterComparisonOperator(_ scanner: PathScanner) -> FilterComparisonOperator? {
    guard let operatorString = scanner.mustMatch(pattern: "\\s*(==|!=|<=|<|>=|>)\\s*") else { return nil }
    switch operatorString.trimmingCharacters(in: .whitespaces) {
    case "==": return .equal
    case "!=": return .notEqual
    case "<": return .lessThan
    case "<=": return .lessThanOrEqual
    case ">": return .greaterThan
    case ">=": return .greaterThanOrEqual
    default: return nil
    }
}

/// parse a filter literal value, e.g. `5`, `'title'`, `true`, or `null`
private func parseFilterValue(_ scanner: PathScanner) -> JsonValue? {
    if let value = scanner.mustMatch(pattern: "\"[^\"\t\r\n]*\"") {
        return String(value.dropFirst().dropLast())
    }
    if let value = scanner.mustMatch(pattern: "'[^'\t\r\n]*'") {
        return String(value.dropFirst().dropLast())
    }
    if scanner.mustMatch(pattern: "true") != nil {
        return true
    }
    if scanner.mustMatch(pattern: "false") != nil {
        return false
    }
    if scanner.mustMatch(pattern: "null") != nil {
        return NSNull()
    }
    if let value = scanner.mustMatch(pattern: "-?[0-9]+\\.[0-9]+") {
        return Double(value)
    }
    if let value = scanner.mustMatch(pattern: "-?[0-9]+") {
        return Int(value)
    }
    return nil
}

/// parse an optional integer, e.g. `-2`
private func optionalInt(_ string: String) -> Int? {
    let trimmed = string.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty else { return nil }
    return Int(trimmed)
}
