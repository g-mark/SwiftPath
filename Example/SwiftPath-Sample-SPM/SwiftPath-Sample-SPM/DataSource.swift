//
//  DataSource.swift
//  SwiftPath-Sample-SPM
//
//  Created by Steven Grosmark on 11/15/20.
//

import Foundation
import SwiftPath

struct Book: Codable, Equatable {
    let title: String
}

struct DataSource {
    
    static var standard: DataSource { DataSource() }
    
    func getBooks() -> [Book] {
        if let jsonPath = SwiftPath("$.books.*"),
           let mapped = try? jsonPath.evaluate(with: fakeJson),
           let data = try? JSONSerialization.data(withJSONObject: mapped),
           let books = try? JSONDecoder().decode([Book].self, from: data) {
            return books
        }
        return []
    }
    
    func getBookTitles() -> [String] {
        if let jsonPath = SwiftPath("$.books.*['title']"),
           let mapped = try? jsonPath.evaluate(with: fakeJson),
           let data = try? JSONSerialization.data(withJSONObject: mapped),
           let books = try? JSONDecoder().decode([String].self, from: data) {
            return books
        }
        return []
    }
    
    private let fakeJson = """
    {
        "books" : {
            "one" : { "title": "one" },
            "two" : { "title": "two" },
            "three" : { "title": "three" }
        }
    }
    """
}
