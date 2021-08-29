//
//  FourDigitSecret.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/29.
//

import XCTest

struct FourDigitSecret {
    let content: (Int, Int, Int, Int)
    
    init?(first: Int, second: Int, third: Int, fourth: Int) {
        return nil
    }
}


class FourDigitSecretTests: XCTestCase {
 
    func test_init_returnsNilOnRepeatedInputs() {
        XCTAssertNil(FourDigitSecret(first: 0, second: 0, third: 0, fourth: 0))
        XCTAssertNil(FourDigitSecret(first: 0, second: 0, third: 2, fourth: 3))
        XCTAssertNil(FourDigitSecret(first: 0, second: 1, third: 1, fourth: 3))
        XCTAssertNil(FourDigitSecret(first: 0, second: 1, third: 2, fourth: 2))
        XCTAssertNil(FourDigitSecret(first: 3, second: 1, third: 2, fourth: 3))
    }
 
    func test_init_returnsNilOnNegativeInputs() {
        XCTAssertNil(FourDigitSecret(first: -1, second: 1, third: 2, fourth: 3))
        XCTAssertNil(FourDigitSecret(first: 0, second: -2, third: 2, fourth: 3))
        XCTAssertNil(FourDigitSecret(first: 0, second: 1, third: -3, fourth: 3))
        XCTAssertNil(FourDigitSecret(first: 0, second: 1, third: 2, fourth: -4))
    }
    
    func test_init_returnsNilOnNonOneDigitInputs() {
        XCTAssertNil(FourDigitSecret(first: 10, second: 1, third: 2, fourth: 3))
        XCTAssertNil(FourDigitSecret(first: 0, second: 11, third: 2, fourth: 3))
        XCTAssertNil(FourDigitSecret(first: 0, second: 1, third: 22, fourth: 3))
        XCTAssertNil(FourDigitSecret(first: 0, second: 1, third: 2, fourth: 33))
    }
}

