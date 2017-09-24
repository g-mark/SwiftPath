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
    
    /// a dot-property
    /// specifies a named property of an object
    ///  .propName
    private static let Dot = literal(string: ".")
    private static let DotPropertyName = pattern(string: "[a-zA-Z_][a-zA-Z0-9_$]*")
    private static let DotProperty = Dot.followed(by: DotPropertyName).map { PathNode.property(name: $0[1]) }
    
    /// quoted properties
    /// used with a subscript to access a property
    /// multiple properties can be comma separated
    ///   ["propName"]
    ///   ["prop1", "propTwo"]
    private static let Quote = literal(string: "\"")
    private static let Comma = pattern(string: "\\s*,\\s*")
    
    private static let SubscriptPropertyName = pattern(string: "[^ \t\r\n\"]+")
    private static let SubscriptProperty = Quote.followed(by: [SubscriptPropertyName, Quote]).map { $0[1] }
    private static let SubscriptPropertyList = SubscriptProperty.repeated(delimiter: Comma).map { list -> PathNode in
        return list.count == 1 ? PathNode.property(name: list[0]) : PathNode.properties(names: list)
    }
    
    /// index value
    /// used to access an item in an array, using a subscript
    /// multiple indices can be comma separated
    ///   [0]
    ///   [0, 2, 4]
    private static let IndexValue = pattern(string: "-?[0-9]+").map { Int($0) }
    private static let IndexValueList = IndexValue.repeated(delimiter: Comma).map { list -> PathNode in
        let flat = list.flatMap { $0 }
        return flat.count == 1 ? PathNode.arrayItem(index: flat[0]) : PathNode.arrayItems(indices: flat)
    }
    
    private static let SubscriptSpecifier = SubscriptPropertyList.or(IndexValueList)
    
    
    private static let OpenSubscript = pattern(string: "\\[\\s*").map { str -> PathNode in PathNode.noop }
    private static let CloseSubscript = pattern(string: "\\s*\\]").map { str -> PathNode in PathNode.noop }
    private static let Subscript = OpenSubscript.followed(by: [SubscriptSpecifier, CloseSubscript]).map { $0[1] }
    
    /// a specifier is either a dot-property or a subscript
    private static let Specifier = DotProperty.or(Subscript)
    
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
    
    SubscriptProperty.run("\"123ghj\"")
    SubscriptPropertyList.run("\"123\", \"abc\", \"himom!\"")
    
    IndexValue.run("")
    IndexValue.run("123")
    IndexValue.run("-37")
    IndexValue.run("-1-1")
    IndexValue.run("333-4")
    IndexValue.run("85-")
    
    IndexValueList.run("42")
    IndexValueList.run("1,12,      56     ,9")
    
    SubscriptSpecifier.run("\"123ghj\"")
    SubscriptSpecifier.run("\"123\", \"abc\", \"himom!\"")
    SubscriptSpecifier.run("42")
    SubscriptSpecifier.run("1,12,      56     ,9")
    
    Subscript.run("[1,2,3]")
    Subscript.run("[0]")
    Subscript.run("[-1]")
    Subscript.run("[]")
    Subscript.run("[\"hello\"]")
    Subscript.run("[\"hello\", \"mother\"]")
    Subscript.run("[\"hello\", 3]")
    
    Specifier.run(".yoyoma")
    Specifier.run("[\"yoyoma\"]")
    Specifier.run("[0]")
    
    Path.run("$[1].hello")
     */
}
