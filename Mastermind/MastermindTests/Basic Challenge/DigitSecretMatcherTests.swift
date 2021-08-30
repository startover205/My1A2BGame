//
//  DigitSecretMatcherTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/30.
//

import XCTest
import Mastermind

final class DigitSecretMatcher {
    private init() {}
    
    static func match(_ guess: FourDigitSecret, with secret: FourDigitSecret) -> (hint: String, correct: Bool) {
        return ("0A0B", false)
    }
}

class DigitSecretMatcherTests: XCTestCase {
    func test_match_deliversFalseWithProperHintOnMatchingNoBullNoCowMatch() {
        let secret = FourDigitSecret(digits: [1, 2, 3, 4])!
        let guess = FourDigitSecret(digits: [5, 6, 7, 8])!
        
        let result = DigitSecretMatcher.match(guess, with: secret)
        
        XCTAssertEqual(result.hint, "0A0B")
        XCTAssertFalse(result.correct)
    }
}
