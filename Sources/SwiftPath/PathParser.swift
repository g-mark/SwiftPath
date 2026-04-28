//
//  PathScanner.swift
//  SwiftPath
//
//  Created by Steven Grosmark on 8/25/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import Foundation

internal struct PathParser {
	
    //MARK: entry point to parse a path
    internal static func parse(path: String) -> PathNode? {
        guard let (node, remnants) = Path.run(path) else { return nil }
        guard remnants.count == 0 else { return nil }
        return node
    }
    
    //MARK: path node parsers
    
    /// root or current node
    /// every path starts with one of these
    ///  $ or @
    private static let Root = literal(string: "$").map { _ in PathNode.root }
    private static let Current = literal(string: "@").map { _ in PathNode.current }
    private static let Node = Root.or(Current)
    
    /// wildcard
    ///  the special "all values" property of an object
    ///   $.book.*
    ///  the special "all items" of an array
    ///   $.books[*]
    private static let Wildcard = literal(string: "*").map { _ in PathNode.arrayValues }
    
    /// a dot-property
    /// specifies a named property of an object
    ///  .propName
    private static let Dot = literal(string: ".")
    private static let DotPropertyName = pattern(string: "(?:[a-zA-Z_][a-zA-Z0-9_$-]*)|\\*")
    private static let DotProperty = Dot.followed(by: DotPropertyName).map { list -> PathNode in
        if list[1] == "*" { return PathNode.values }
        return PathNode.property(name: list[1])
    }
        
    /// quoted properties
    /// used with a subscript to access a property
    /// multiple properties can be comma separated
    ///   ["propName"] or ['propName']
    ///   ["prop1", "propTwo"] or ['prop1', "prop2"]
    private static let Quote = literal(string: "\"")
    private static let SingleQuote = literal(string: "'")
    private static let Comma = pattern(string: "\\s*,\\s*")
    
    private static let QuotedPropertyNameContent = pattern(string: "[^\t\r\n\"\']+")
    private static let DoubleQuotedPropertyName = Quote.followed(by: [QuotedPropertyNameContent, Quote]).map { $0[1] }
    private static let SingleQuotedPropertyName = SingleQuote.followed(by: [QuotedPropertyNameContent, SingleQuote]).map { $0[1] }
    
    // subscript property parser -> String
    private static let QuotedPropertyName = DoubleQuotedPropertyName.or(SingleQuotedPropertyName)

    /// array filter paths support dot-properties and quoted subscript properties.
    private static let FilterOpenBracket = pattern(string: "\\[\\s*").map { _ in PathNode.noop }
    private static let FilterCloseBracket = pattern(string: "\\s*\\]").map { _ in PathNode.noop }
    private static let FilterBracketProperty = FilterOpenBracket.followed(by: [
        QuotedPropertyName.map { PathNode.property(name: $0) },
        FilterCloseBracket
    ]).map { $0[1] }
    private static let FilterPathSpecifier = DotProperty.or(FilterBracketProperty)
    private static let FilterPathSpecifiers = FilterPathSpecifier.zeroOrMore().map { PathNode.nodes(nodes: $0) }
    private static let FilterPath = Node.followed(by: FilterPathSpecifiers).map { result -> PathNode? in
        guard case let .nodes(nodes) = result[1] else { return nil }
        return PathNode.path(base: result[0], nodes: nodes)
    }
    
    // subscript property parser -> (String, String)
    private static let PropertySelection = QuotedPropertyName.map { name -> (String, String) in
        return (name, name)
    }
    
    private static let RenameArrow = pattern(string: "\\s*=>\\s*")
    private static let RenameTarget = RenameArrow.followed(by: QuotedPropertyName).map { str -> (String, String) in return (str[1], str[1]) }
    
    private static let RenameablePropertySelection = PropertySelection.followed(by: RenameTarget, required: false).map { list -> (String, String) in
        guard list.count > 1 else { return list[0] }
        return (list[0].0, list[1].0)
    }
    
    private static let PropertySelectionList = RenameablePropertySelection.repeated(delimiter: Comma).map { list -> PathNode in
        guard list.count > 1 else { return PathNode.property(name: list[0].0) }
        let (names, rename) = list.reduce(into: ([String](), [String]())) {
            $0.0.append($1.0)
            $0.1.append($1.1)
        }
        return PathNode.properties(names: names, rename: rename)
    }
    
    /// index value
    /// used to access an item in an array, using a subscript
    /// multiple indices can be comma separated
    ///   [0]
    ///   [0, 2, 4]
    private static let IndexValue = pattern(string: "-?[0-9]+").map { Int($0) }
    private static let IndexValueList = IndexValue.repeated(delimiter: Comma).map { list -> PathNode in
        let flat = list.compactMap { $0 }
        return flat.count == 1 ? PathNode.arrayItem(index: flat[0]) : PathNode.arrayItems(indices: flat)
    }

    /// filter
    /// used to select items in an array
    ///   [?(@.id==5)]
    private static let ArrayFilterSpecifier = Parser<PathNode>(parse: { scanner in
        guard let (_, filterScanner) = token(string: "?").parse(scanner) else { return nil }
        guard let (expression, expressionScanner) = FilterExpressionParser.parse(filterScanner) else { return nil }
        return (PathNode.arrayFilter(filter: ArrayFilter(expression: expression)), expressionScanner)
    })

    private static var FilterExpressionParser: Parser<FilterExpression> {
        return Parser<FilterExpression>.lazy { FilterOrExpression }
    }

    private static var FilterOrExpression: Parser<FilterExpression> {
        return FilterAndExpression.chainLeft(operator: FilterOrOperator)
    }

    private static var FilterAndExpression: Parser<FilterExpression> {
        return FilterNotExpression.chainLeft(operator: FilterAndOperator)
    }

    private static var FilterNotExpression: Parser<FilterExpression> {
        return Parser<FilterExpression>(parse: { scanner in
            if let (_, notScanner) = token(string: "!").parse(scanner) {
                guard let (expression, expressionScanner) = Self.FilterNotExpression.parse(notScanner) else { return nil }
                return (.not(expression), expressionScanner)
            }
            return FilterPrimaryExpression.parse(scanner)
        })
    }

    private static var FilterPrimaryExpression: Parser<FilterExpression> {
        return FilterComparisonExpression.attempt().or(FilterExistenceExpression).or(FilterParenthesizedExpression)
    }

    private static var FilterComparisonExpression: Parser<FilterExpression> {
        return Parser<FilterExpression>(parse: { scanner in
            guard let (path, pathScanner) = parseFilterPath(scanner) else { return nil }
            guard let comparisonOperator = parseFilterComparisonOperator(pathScanner) else { return nil }
            guard let expectedValue = parseFilterValue(pathScanner) else { return nil }
            return (.comparison(path, comparisonOperator, expectedValue), pathScanner)
        })
    }

    private static var FilterExistenceExpression: Parser<FilterExpression> {
        return Parser<FilterExpression>(parse: { scanner in
            guard let (path, pathScanner) = parseFilterPath(scanner) else { return nil }
            return (.exists(path), pathScanner)
        })
    }

    private static var FilterParenthesizedExpression: Parser<FilterExpression> {
        return Parser<FilterExpression>(parse: { scanner in
            guard let (_, openScanner) = token(string: "(").parse(scanner) else { return nil }
            guard let (expression, expressionScanner) = FilterExpressionParser.parse(openScanner) else { return nil }
            guard let (_, closeScanner) = token(string: ")").parse(expressionScanner) else { return nil }
            return (expression, closeScanner)
        })
    }

    private static var FilterAndOperator: Parser<(FilterExpression, FilterExpression) -> FilterExpression> {
        return token(string: "&&").map { _ in
            { (lhs: FilterExpression, rhs: FilterExpression) in .and(lhs, rhs) }
        }
    }

    private static var FilterOrOperator: Parser<(FilterExpression, FilterExpression) -> FilterExpression> {
        return token(string: "||").map { _ in
            { (lhs: FilterExpression, rhs: FilterExpression) in .or(lhs, rhs) }
        }
    }

    private static func parseFilterPath(_ scanner: PathScanner) -> (JsonPathPart, PathScanner)? {
        guard let (parsedPath, pathScanner) = FilterPath.parse(scanner), let pathNode = parsedPath else { return nil }
        guard case let .path(base, nodes) = pathNode else { return nil }
        return (JsonPathPart(parts: [base] + nodes), pathScanner)
    }

    private static let BracketSpecifier = PropertySelectionList.or(IndexValueList).or(Wildcard).or(ArrayFilterSpecifier)
    
    
    private static let OpenBracket = pattern(string: "\\[\\s*").map { str -> PathNode in PathNode.noop }
    private static let CloseBracket = pattern(string: "\\s*\\]").map { str -> PathNode in PathNode.noop }
    private static let BracketSelector = OpenBracket.followed(by: [BracketSpecifier, CloseBracket]).map { $0[1] }
    
    /// a specifier is either a dot-property or a subscript
    private static let Specifier = DotProperty.or(BracketSelector)
    
    /// a sequence of zero or more specifiers
    private static let Specifiers = Specifier.zeroOrMore().map { PathNode.nodes(nodes: $0) }
    
    /// a full path starts with a root or current node, optionally followed by zero or more specifiers
    private static let ReferenceNode = Root.or(Current)
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
