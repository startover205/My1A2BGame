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
        let invalidResult = MatchResult(bulls: 0, cows: 0, correct: false)
        
        expect(guess: [1], matching: [1, 2, 3, 4], toCompleteWith: invalidResult)
        expect(guess: [1, 2], matching: [1, 2, 3, 4], toCompleteWith: invalidResult)
        expect(guess: [1, 2, 3], matching: [1, 2, 3, 4], toCompleteWith: invalidResult)
        expect(guess: [1, 2, 3, 4, 5], matching: [1, 2, 3, 4], toCompleteWith: invalidResult)
    }
    
    func test_match_deliversFalseWithProperHintOnMatchingNoBullNoCowMatch() {
        expect(guess: [1, 2, 3, 4], matching: [5, 6, 7, 8], toCompleteWith: MatchResult(bulls: 0, cows: 0, correct: false))
    }
    
    func test_match_deliversFalseWithProperHintOnMatchingNoBullPartialCowsMatch() {
        expect(guess: [1, 2, 3, 4], matching: [5, 1, 7, 8], toCompleteWith: MatchResult(bulls: 0, cows: 1, correct: false))
        expect(guess: [1, 2, 3, 4], matching: [5, 1, 7, 2], toCompleteWith: MatchResult(bulls: 0, cows: 2, correct: false))
        expect(guess: [1, 2, 3, 4], matching: [5, 1, 2, 3], toCompleteWith: MatchResult(bulls: 0, cows: 3, correct: false))
    }
    
    func test_match_deliversFalseWithProperHintOnMatchingNoBullFullCowsMatch() {
        expect(guess: [1, 2, 3, 4], matching: [4, 1, 2, 3], toCompleteWith: MatchResult(bulls: 0, cows: 4, correct: false))
    }
    
    func test_match_deliversFalseWithProperHintOnMatchingPartialBullsPartialCowsMatch() {
        expect(guess: [1, 2, 3, 4], matching: [1, 6, 2, 8], toCompleteWith: MatchResult(bulls: 1, cows: 1, correct: false))
        expect(guess: [1, 2, 3, 4], matching: [1, 6, 2, 3], toCompleteWith: MatchResult(bulls: 1, cows: 2, correct: false))
        expect(guess: [1, 2, 3, 4], matching: [1, 4, 2, 3], toCompleteWith: MatchResult(bulls: 1, cows: 3, correct: false))
        expect(guess: [1, 2, 3, 4], matching: [1, 2, 7, 3], toCompleteWith: MatchResult(bulls: 2, cows: 1, correct: false))
        expect(guess: [1, 2, 3, 4], matching: [1, 2, 4, 3], toCompleteWith: MatchResult(bulls: 2, cows: 2, correct: false))
    }
    
    func test_match_deliversFalseWithProperHintOnMatchingPartialBullsNoCowsMatch() {
        expect(guess: [1, 2, 3, 4], matching: [1, 6, 7, 8], toCompleteWith: MatchResult(bulls: 1, cows: 0, correct: false))
        expect(guess: [1, 2, 3, 4], matching: [5, 2, 3, 8], toCompleteWith: MatchResult(bulls: 2, cows: 0, correct: false))
        expect(guess: [1, 2, 3, 4], matching: [1, 6, 3, 4], toCompleteWith: MatchResult(bulls: 3, cows: 0, correct: false))
    }
    
    func test_match_deliversTrueWithProperHintOnMatchingFullBullsNoCowMatch() {
        expect(guess: [1, 2, 3, 4], matching: [1, 2, 3, 4], toCompleteWith: MatchResult(bulls: 4, cows: 0, correct: true))
        expect(guess: [5, 6, 7, 8], matching: [5, 6, 7, 8], toCompleteWith: MatchResult(bulls: 4, cows: 0, correct: true))
        expect(guess: [0, 9, 6, 4], matching: [0, 9, 6, 4], toCompleteWith: MatchResult(bulls: 4, cows: 0, correct: true))
    }
    
    // MARK: - Helpers

    private func expect(guess: [Int], matching secret: [Int], toCompleteWith expectedResult: MatchResult, file: StaticString = #filePath, line: UInt = #line) {
        let secret = DigitSecret(digits: secret)!
        let guess = DigitSecret(digits: guess)!
        
        let result = DigitSecretMatcher.matchGuess(guess, with: secret)
        
        XCTAssertEqual(result, expectedResult)
    }
}
