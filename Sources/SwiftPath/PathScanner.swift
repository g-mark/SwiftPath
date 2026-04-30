//
//  PathScanner.swift
//  SwiftPath
//
//  Created by Steven Grosmark on 8/25/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import Foundation

// @unchecked Sendable: PathScanner is created, used, and discarded within a single
// synchronous call on one thread. It never escapes across isolation boundaries.
final class PathScanner: @unchecked Sendable {
    
	let source: String
	private(set) var startIndex: String.Index
	let endIndex: String.Index
	
	private var indexStack:[String.Index]
	
	init(string: String) {
		self.source = string
		startIndex = source.startIndex
		endIndex = source.endIndex
		indexStack = []
	}
	
	func pushLocation() {
		indexStack.append(startIndex)
	}
	func popLocation() {
		startIndex = indexStack.removeLast()
	}
	func dropLocation() {
		indexStack.removeLast()
	}
	
	var hasMore: Bool { return startIndex < endIndex }
	
	func mustBe(string: String) -> Bool {
		if matches(string: string) {
			advance(by: string.count)
			return true
		}
		return false
	}
	
	func mustMatch(pattern: String ) -> String? {
		if let match = match(pattern: pattern) {
			startIndex = match.upperBound
			return match.value
		}
		return nil
	}
	
	
	func matches(string: String) -> Bool {
		return source[startIndex..<endIndex].hasPrefix(string)
	}
	
	func matches(pattern: String) -> String? {
		return match(pattern: pattern)?.value
	}

	private func match(pattern: String) -> (value: String, upperBound: String.Index)? {
		guard let found = source.range(of: pattern, options: [.regularExpression, .anchored], range: startIndex..<endIndex) else {
			return nil
		}
        #if os(Linux)
            // https://github.com/swiftlang/swift-corelibs-foundation/issues/5467
            // With `.anchored`, any real match must begin at the scanner's current
            // position. swift-corelibs-foundation can report a bogus empty match at
            // `source.startIndex` when matching a non-zero range on Linux; rejecting
            // ranges that do not begin at `startIndex` filters that out without
            // copying the remaining input into a temporary substring.
            guard found.lowerBound == startIndex else {
                return nil
            }
        #endif
		return (String(source[found]), found.upperBound)
	}
	
	func skipWhitespace() {
		skip(charactersIn: "\(CharacterSet.whitespaces)")
	}
	
	func skip(_ characters: CharacterSet) {
		skip(charactersIn: "\(characters)")
	}
	
	func skip(charactersIn characters: String) {
		while startIndex < endIndex, characters.contains(source[startIndex]) {
			startIndex = source.index(startIndex, offsetBy: 1)
		}
	}
	
	var contextString: String { return String(source[startIndex..<endIndex]) }
	
	func advance(by amount: Int) {
		startIndex = source.index(startIndex, offsetBy: amount)
	}
    
}
