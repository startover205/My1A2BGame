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
        expect(guess: [1, 2, 3, 4], matching: [5, 6, 7, 8], toCompleteWith: (hint: "0A0B", correct: false))
    }
    
    func test_match_deliversFalseWithProperHintOnMatchingNoBullPartialCowsMatch() {
        expect(guess: [1, 2, 3, 4], matching: [5, 1, 7, 8], toCompleteWith: (hint: "0A1B", correct: false))
        expect(guess: [1, 2, 3, 4], matching: [5, 1, 7, 2], toCompleteWith: (hint: "0A2B", correct: false))
        expect(guess: [1, 2, 3, 4], matching: [5, 1, 2, 3], toCompleteWith: (hint: "0A3B", correct: false))
        expect(guess: [1, 2, 3, 4], matching: [4, 1, 2, 3], toCompleteWith: (hint: "0A4B", correct: false))
    }
    
    // MARK: - Helpers

    private func expect(guess: [Int], matching secret: [Int], toCompleteWith expectedResult: (hint: String, correct: Bool), file: StaticString = #filePath, line: UInt = #line) {
        let secret = FourDigitSecret(digits: secret)!
        let guess = FourDigitSecret(digits: guess)!
        
        let result = DigitSecretMatcher.match(guess, with: secret)
        
        XCTAssertEqual(result.hint, expectedResult.hint, file: file, line: line)
        XCTAssertEqual(result.correct, expectedResult.correct, file: file, line: line)
    }
}
