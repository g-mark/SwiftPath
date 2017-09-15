//
//  PathArrayFunctionTestes.swift
//  JsonPathTests
//
//  Created by Steven Grosmark on 8/20/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import XCTest
@testable import JsonPathLib

class PathArrayFunctionTestes: XCTestCase {
	
	let positives = [ 980.87, 509.42, 11.98, 165.31, 791.29, 834.18, 68.69, 817.87, 994.97, 862.40 ]
	let negatives = [ -194.65, -790.89, -696.61, -322.70, -803.83, -57.13, -162.76, -646.61, -260.87, -934.49 ]
	let mixed = [ -96.70, 0.89, -44.27, 43.30, -20.33, -69.67, -57.39, 96.88, -86.54, 27.12 ]
	let zeros = [ 0.0, 0.0, 0.0 ]
	let infinity = [-Double.infinity, 0.0, Double.infinity]
	let nan = [ Double.nan ]
	let one = [ 1.0 ]
	let empty: [Double] = []
	let garbage: [Any] = [ "string", 3.0, ["string":1.1], true ]
	
	struct Test {
		let numbers: [Any]
		let function: ArrayFunction
		let expectedResult: Double
		
		init(numbers: [Any], function: ArrayFunction, expectedResult: Double = .nan) {
			self.numbers = numbers
			self.function = function
			self.expectedResult = expectedResult
		}
	}
	
	override func setUp() {
		super.setUp()
		
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testBadInput() {
		let tests = [
			Test(numbers: empty, function: .minimum),
			Test(numbers: empty, function: .maximum),
			Test(numbers: empty, function: .average),
			Test(numbers: empty, function: .standardDeviation),
			Test(numbers: one, function: .standardDeviation),
			
			Test(numbers: garbage, function: .minimum),
			Test(numbers: garbage, function: .maximum),
			Test(numbers: garbage, function: .average),
			Test(numbers: garbage, function: .sum),
			Test(numbers: garbage, function: .standardDeviation)
		]
		
		for test in tests {
			XCTAssertThrowsError(try test.function.evaluate(array: test.numbers), "\(test.function) expected to throw on \(test.numbers)") {error in
				
			}
		}
	}
	
	func testValid() {
		let tests = [
			Test(numbers: positives, function: .minimum, expectedResult: 11.98),
			Test(numbers: negatives, function: .minimum, expectedResult: -934.49),
			Test(numbers: mixed, function: .minimum, expectedResult: -96.70),
			Test(numbers: zeros, function: .minimum, expectedResult: 0),
			Test(numbers: infinity, function: .minimum, expectedResult: -Double.infinity),
			Test(numbers: one, function: .minimum, expectedResult: 1),
			
			Test(numbers: positives, function: .maximum, expectedResult: 994.97),
			Test(numbers: negatives, function: .maximum, expectedResult: -57.13),
			Test(numbers: mixed, function: .maximum, expectedResult: 96.88),
			Test(numbers: zeros, function: .maximum, expectedResult: 0),
			Test(numbers: infinity, function: .maximum, expectedResult: Double.infinity),
			Test(numbers: one, function: .maximum, expectedResult: 1),
			
			Test(numbers: positives, function: .average, expectedResult: 603.698),
			Test(numbers: negatives, function: .average, expectedResult: -487.054),
			Test(numbers: mixed, function: .average, expectedResult: -20.671),
			Test(numbers: zeros, function: .average, expectedResult: 0),
			Test(numbers: infinity, function: .average, expectedResult: Double.nan),
			Test(numbers: one, function: .average, expectedResult: 1),
			
			Test(numbers: positives, function: .sum, expectedResult: 6036.98),
			Test(numbers: negatives, function: .sum, expectedResult: -4870.54),
			Test(numbers: mixed, function: .sum, expectedResult: -206.71),
			Test(numbers: zeros, function: .sum, expectedResult: 0),
			Test(numbers: infinity, function: .sum, expectedResult: Double.nan),
			Test(numbers: one, function: .sum, expectedResult: 1),
			Test(numbers: empty, function: .sum, expectedResult: 0),
			
			Test(numbers: positives, function: .standardDeviation, expectedResult: 365.22564369989),
			Test(numbers: negatives, function: .standardDeviation, expectedResult: 302.63954467981),
			Test(numbers: mixed, function: .standardDeviation, expectedResult: 59.232366903577),
			Test(numbers: zeros, function: .standardDeviation, expectedResult: 0),
			Test(numbers: infinity, function: .standardDeviation, expectedResult: Double.nan),
			
			Test(numbers: positives, function: .length, expectedResult: 10),
			Test(numbers: one, function: .length, expectedResult: 1),
			Test(numbers: empty, function: .length, expectedResult: 0),
			]
		
		// expected precision
		let precision = 1E-10
		
		// some oddball comparisons that came up:
		//  comparing -487.054 with -487.054 - diff is 1.13686837721616e-13
		//  comparing -20.671 with -20.671 - diff is 3.5527136788005e-15
		//  comparing 365.22564369989 with 365.225643699891 - diff is 1.36424205265939e-12
		//  comparing 302.63954467981 with 302.639544679806 - diff is 4.49063009000383e-12
		//  comparing 59.232366903577 with 59.2323669035773 - diff is 3.05533376376843e-13
		
		for test in tests {
			do {
				if let result = try test.function.evaluate(array: test.numbers) as? Double {
					let equal:Bool
					if test.expectedResult.isInfinite {
						equal = result.isInfinite && test.expectedResult.sign == result.sign
					}
					else if test.expectedResult.isNaN {
						equal = result.isNaN
					}
					else {
						equal = abs(test.expectedResult - result) < precision
					}
					XCTAssert(equal, "\(test.function) failed: expecting \(test.expectedResult) got \(result) for \(test.numbers)")
				}
				else {
					XCTFail("\(test.function) failed for \(test.numbers) - no return value")
				}
			}
			catch {
				XCTFail("\(test.function) failed for \(test.numbers) - \(error)")
			}
		}
	}
    
}
