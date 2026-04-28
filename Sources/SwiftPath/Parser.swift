//
//  Parser.swift
//  SwiftPath
//
//  Created by Steven Grosmark on 8/25/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import Foundation

// @unchecked Sendable: Parser<T> is an immutable struct whose stored closure
// either is a pure function or captures only other immutable Parser instances.
// All parsing executes synchronously on the calling thread with no shared mutable state.
internal struct Parser<T>: @unchecked Sendable {
    let parse: (PathScanner) -> (T, PathScanner)?
}

extension Parser {

    /// create a parser whose implementation is built when it runs
    internal static func lazy(_ parser: @escaping () -> Parser<T>) -> Parser<T> {
        return Parser<T>(parse: { scanner in
            parser().parse(scanner)
        })
    }
    
    /// run a parser against a string and return the result with unparsed remnants
    internal func run(_ string: String) -> (T, String)? {
        guard let (result, remainder) = parse(PathScanner(string: string)) else { return nil }
        return (result, remainder.contextString)
    }
    
    /// this parser followed by another parser of the same type
    internal func followed(by rparser:Parser, required: Bool = true) -> Parser<[T]> {
        return Parser<[T]>(parse: { scanner in
            guard let (lvalue, lscanner) = self.parse(scanner) else { return nil }
            if let (rvalue, rscanner) = rparser.parse(lscanner) {
                return ([lvalue, rvalue], rscanner)
            }
            guard !required else { return nil }
            return ([lvalue], lscanner)
        })
    }
    
    /// this parser followed by a list of parsers of the same type
    internal func followed(by rparsers:[Parser]) -> Parser<[T]> {
        return Parser<[T]>(parse: { scanner in
            guard let (lvalue, lscanner) = self.parse(scanner) else { return nil }
            var scanner = lscanner
            var collected = [lvalue]
            for rparser in rparsers {
                guard let (rvalue, rscanner) = rparser.parse(scanner) else { return nil }
                collected.append(rvalue)
                scanner = rscanner
            }
            return (collected, scanner)
        })
    }
    
    /// this parser or another parser of the same type; use attempt to roll back consumed input
    internal func or(_ rparser: Parser) -> Parser<T> {
        return Parser<T>(parse: { scanner in
            return self.parse(scanner) ?? rparser.parse(scanner)
        })
    }

    /// restore the scanner position if this parser fails
    internal func attempt() -> Parser<T> {
        return Parser<T>(parse: { scanner in
            scanner.pushLocation()
            if let result = self.parse(scanner) {
                scanner.dropLocation()
                return result
            }
            scanner.popLocation()
            return nil
        })
    }

    /// return nil without consuming input when this parser does not match
    internal func optional() -> Parser<T?> {
        return Parser<T?>(parse: { scanner in
            scanner.pushLocation()
            if let (result, resultScanner) = self.parse(scanner) {
                scanner.dropLocation()
                return (result, resultScanner)
            }
            scanner.popLocation()
            return (nil, scanner)
        })
    }

    /// parse left-associative binary expressions with this parser as the term
    internal func chainLeft(operator op: Parser<(T, T) -> T>) -> Parser<T> {
        return Parser<T>(parse: { scanner in
            guard let (initialValue, initialScanner) = self.parse(scanner) else { return nil }
            var result = initialValue
            var scanner = initialScanner

            while true {
                scanner.pushLocation()
                guard let (combine, operatorScanner) = op.parse(scanner),
                      let (nextValue, nextScanner) = self.parse(operatorScanner) else {
                    scanner.popLocation()
                    break
                }
                scanner.dropLocation()
                result = combine(result, nextValue)
                scanner = nextScanner
            }

            return (result, scanner)
        })
    }
    
    /// one or more repetitions of this parser
    internal func repeated() -> Parser<[T]> {
        return Parser<[T]>(parse: { scanner in
            guard let (lvalue, lscanner) = self.parse(scanner) else { return nil }
            var scanner = lscanner
            var collected = [lvalue]
            while let (rvalue, rscanner) = self.parse(scanner) {
                collected.append(rvalue)
                scanner = rscanner
            }
            return (collected, scanner)
        })
    }
    
    /// one or more repetitions of this parser separated by a delimiter
    internal func repeated<A>(delimiter: Parser<A>) -> Parser<[T]> {
        return Parser<[T]>(parse: { scanner in
            guard let (lvalue, lscanner) = self.parse(scanner) else { return nil }
            var scanner = lscanner
            var collected = [lvalue]
            while let (_, rscanner) = delimiter.parse(scanner) {
                guard let (rvalue, rscanner) = self.parse(rscanner) else { return nil }
                collected.append(rvalue)
                scanner = rscanner
            }
            return (collected, scanner)
        })
    }
    
    /// zero or more repetitions of this parser
    internal func zeroOrMore() -> Parser<[T]> {
        return Parser<[T]>(parse: { scanner in
            guard let (lvalue, lscanner) = self.parse(scanner) else { return ([], scanner) }
            var scanner = lscanner
            var collected = [lvalue]
            while let (rvalue, rscanner) = self.parse(scanner) {
                collected.append(rvalue)
                scanner = rscanner
            }
            return (collected, scanner)
        })
    }
    
    /// transform this parser's result
    internal func map<TResult>(_ transform: @escaping (T) -> TResult) -> Parser<TResult> {
        return Parser<TResult> { scanner in
            guard let (result, remainder) = self.parse(scanner) else { return nil }
            return (transform(result), remainder)
        }
    }
    
    
}


/// parse a literal string
func literal(string: String) -> Parser<String> {
    return Parser<String>(parse: { scanner in
        guard scanner.mustBe(string: string) else {
            return nil
        }
        return (string, scanner)
    })
}


/// parse an anchored regular expression pattern
func pattern(string: String) -> Parser<String> {
    return Parser<String>(parse: { scanner in
        guard let match = scanner.mustMatch(pattern: string) else {
            return nil
        }
        return (match, scanner)
    })
}

/// parse a literal string with optional surrounding whitespace
func token(string: String) -> Parser<String> {
    return Parser<String>(parse: { scanner in
        scanner.pushLocation()
        _ = scanner.mustMatch(pattern: "\\s*")
        guard scanner.mustBe(string: string) else {
            scanner.popLocation()
            return nil
        }
        _ = scanner.mustMatch(pattern: "\\s*")
        scanner.dropLocation()
        return (string, scanner)
    })
}

/// parse an anchored regular expression pattern with optional surrounding whitespace
func tokenPattern(string: String) -> Parser<String> {
    return Parser<String>(parse: { scanner in
        scanner.pushLocation()
        _ = scanner.mustMatch(pattern: "\\s*")
        guard let match = scanner.mustMatch(pattern: string) else {
            scanner.popLocation()
            return nil
        }
        _ = scanner.mustMatch(pattern: "\\s*")
        scanner.dropLocation()
        return (match, scanner)
    })
}
