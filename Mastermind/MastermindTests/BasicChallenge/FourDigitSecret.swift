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
        XCTAssertNil(FourDigitSecret(first: 1, second: 2, third: 3, fourth: 3))
        XCTAssertNil(FourDigitSecret(first: 9, second: 8, third: 7, fourth: 7))
    }
 
    func test_init_returnsNilOnNegativeInputs() {
        XCTAssertNil(FourDigitSecret(first: -1, second: 0, third: 1, fourth: 2))
    }
}

