//
//  SwiftPath_Sample_SPMTests.swift
//  SwiftPath-Sample-SPMTests
//
//  Created by Steven Grosmark on 11/15/20.
//

import XCTest
@testable import SwiftPath_Sample_SPM

class SwiftPath_Sample_SPMTests: XCTestCase {

    func testExample() throws {
        XCTAssertEqual(
            DataSource.standard.getBooks().sorted(by: { $0.title < $1.title }),
            [Book(title: "one"), Book(title: "three"), Book(title: "two")]
        )
        XCTAssertEqual(
            DataSource.standard.getBookTitles().sorted(),
            ["one", "three", "two"]
        )
    }

}
