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
 
    func test_init_returnsNilOnRepeatedDigits() {
        XCTAssertNil(FourDigitSecret(first: 0, second: 0, third: 0, fourth: 0))
    }
    
}
