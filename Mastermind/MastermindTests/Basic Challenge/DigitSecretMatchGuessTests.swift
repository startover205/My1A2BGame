//
//  DigitSecretMatchGuessTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/9/22.
//

import XCTest
import Mastermind

class DigitSecretMatchGuessTests: XCTestCase {
    func test_match_deliversFalseWithProperHintOnMatchingGuessWithUnmatchingLength() {
        expect(guess: [1], matching: [1, 2, 3, 4], toCompleteWith: (hint: "mismatch length", correct: false))
        expect(guess: [1, 2], matching: [1, 2, 3, 4], toCompleteWith: (hint: "mismatch length", correct: false))
        expect(guess: [1, 2, 3], matching: [1, 2, 3, 4], toCompleteWith: (hint: "mismatch length", correct: false))
        expect(guess: [1, 2, 3, 4, 5], matching: [1, 2, 3, 4], toCompleteWith: (hint: "mismatch length", correct: false))
    }
    
    func test_match_deliversFalseWithProperHintOnMatchingNoBullNoCowMatch() {
        expect(guess: [1, 2, 3, 4], matching: [5, 6, 7, 8], toCompleteWith: (hint: "0A0B", correct: false))
    }
    
    func test_match_deliversFalseWithProperHintOnMatchingNoBullPartialCowsMatch() {
        expect(guess: [1, 2, 3, 4], matching: [5, 1, 7, 8], toCompleteWith: (hint: "0A1B", correct: false))
        expect(guess: [1, 2, 3, 4], matching: [5, 1, 7, 2], toCompleteWith: (hint: "0A2B", correct: false))
        expect(guess: [1, 2, 3, 4], matching: [5, 1, 2, 3], toCompleteWith: (hint: "0A3B", correct: false))
    }
    
    func test_match_deliversFalseWithProperHintOnMatchingNoBullFullCowsMatch() {
        expect(guess: [1, 2, 3, 4], matching: [4, 1, 2, 3], toCompleteWith: (hint: "0A4B", correct: false))
    }
    
    func test_match_deliversFalseWithProperHintOnMatchingPartialBullsPartialCowsMatch() {
        expect(guess: [1, 2, 3, 4], matching: [1, 6, 2, 8], toCompleteWith: (hint: "1A1B", correct: false))
        expect(guess: [1, 2, 3, 4], matching: [1, 6, 2, 3], toCompleteWith: (hint: "1A2B", correct: false))
        expect(guess: [1, 2, 3, 4], matching: [1, 4, 2, 3], toCompleteWith: (hint: "1A3B", correct: false))
        expect(guess: [1, 2, 3, 4], matching: [1, 2, 7, 3], toCompleteWith: (hint: "2A1B", correct: false))
        expect(guess: [1, 2, 3, 4], matching: [1, 2, 4, 3], toCompleteWith: (hint: "2A2B", correct: false))
    }
    
    func test_match_deliversFalseWithProperHintOnMatchingPartialBullsNoCowsMatch() {
        expect(guess: [1, 2, 3, 4], matching: [1, 6, 7, 8], toCompleteWith: (hint: "1A0B", correct: false))
        expect(guess: [1, 2, 3, 4], matching: [5, 2, 3, 8], toCompleteWith: (hint: "2A0B", correct: false))
        expect(guess: [1, 2, 3, 4], matching: [1, 6, 3, 4], toCompleteWith: (hint: "3A0B", correct: false))
    }
    
    func test_match_deliversTrueWithProperHintOnMatchingFullBullsNoCowMatch() {
        expect(guess: [1, 2, 3, 4], matching: [1, 2, 3, 4], toCompleteWith: (hint: "4A0B", correct: true))
        expect(guess: [5, 6, 7, 8], matching: [5, 6, 7, 8], toCompleteWith: (hint: "4A0B", correct: true))
        expect(guess: [0, 9, 6, 4], matching: [0, 9, 6, 4], toCompleteWith: (hint: "4A0B", correct: true))
    }
    
    // MARK: - Helpers

    private func expect(guess: [Int], matching secret: [Int], toCompleteWith expectedResult: (hint: String, correct: Bool), file: StaticString = #filePath, line: UInt = #line) {
        let secret = DigitSecret(digits: secret)!
        let guess = DigitSecret(digits: guess)!
        
        let result = DigitSecretMatcher.match(guess, with: secret)
        
        XCTAssertEqual(result.hint, expectedResult.hint, file: file, line: line)
        XCTAssertEqual(result.correct, expectedResult.correct, file: file, line: line)
    }
}
