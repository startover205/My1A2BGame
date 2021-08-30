//
//  FourDigitSecret.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/29.
//

import XCTest
import Mastermind

class FourDigitSecretTests: XCTestCase {
 
    func test_init_returnsNilOnRepeatedInputs() {
        XCTAssertNil(makeSUT(digits: [0, 0, 0, 0]))
        XCTAssertNil(makeSUT(digits: [0, 1, 1, 3]))
        XCTAssertNil(makeSUT(digits: [0, 1, 2, 2]))
        XCTAssertNil(makeSUT(digits: [3, 1, 2, 3]))
    }
 
    func test_init_returnsNilOnNegativeInputs() {
        XCTAssertNil(makeSUT(digits: [-1, 1, 2, 3]))
        XCTAssertNil(makeSUT(digits: [0, -2, 2, 3]))
        XCTAssertNil(makeSUT(digits: [0, 1, -3, 3]))
        XCTAssertNil(makeSUT(digits: [0, 1, 2, -4]))
    }
    
    func test_init_returnsNilOnNonOneDigitInputs() {
        XCTAssertNil(makeSUT(digits: [10, 1, 2, 3]))
        XCTAssertNil(makeSUT(digits: [0, 11, 2, 3]))
        XCTAssertNil(makeSUT(digits: [0, 1, 22, 3]))
        XCTAssertNil(makeSUT(digits: [0, 1, 2, 33]))
    }
    
    func test_init_successfully() {
        XCTAssertNotNil(makeSUT(digits: [0, 1, 2, 3]))
        XCTAssertNotNil(makeSUT(digits: [2, 3, 4, 5]))
        XCTAssertNotNil(makeSUT(digits: [9, 8, 7, 6]))
        XCTAssertNotNil(makeSUT(digits: [3, 9, 2, 0]))
    }
    
    // MARK: Helpers
    
    private func makeSUT(digits: [Int], file: StaticString = #filePath, line: UInt = #line) -> FourDigitSecret? {
        let sut = FourDigitSecret(first: digits[0], second: digits[1], third: digits[2], fourth: digits[3])
        
        return sut
    }
}

