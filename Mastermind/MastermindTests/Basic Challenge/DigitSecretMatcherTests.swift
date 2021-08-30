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
        var correctCount = 0
        var misplacedCount = 0
        
        guess.content.enumerated().forEach { guessIndex, guessDigit in
            secret.content.enumerated().forEach { answerIndex, answerDigit in
                if guessDigit == answerDigit {
                    guessIndex == answerIndex ? (correctCount += 1) : (misplacedCount += 1)
                }
            }
        }
        
        return ("\(correctCount)A\(misplacedCount)B", false)
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
    
    func test_match_deliversFalseWithProperHintOnMatchingNoBullOneCowMatch() {
        let secret = FourDigitSecret(digits: [1, 2, 3, 4])!
        let guess = FourDigitSecret(digits: [5, 1, 7, 8])!
        
        let result = DigitSecretMatcher.match(guess, with: secret)
        
        XCTAssertEqual(result.hint, "0A1B")
        XCTAssertFalse(result.correct)
    }
}
