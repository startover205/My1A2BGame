//
//  MastermindEvaluatorTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/7/20.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame

class MastermindEvaluatorTests: XCTestCase {
    func test_evaluate_throwsErrorOnMismatchLengthInputs() {
        let guess = [1, 2, 3, 4]
        let answer = [1, 2, 3, 4, 5]

        XCTAssertThrowsError(
            try MastermindEvaluator.evaluate(guess, with: answer)
        )
    }
    
    func test_evaluate_throwsErrorOnDuplicateNumberAnswerInput() {
        let guess = [1, 2, 3, 4]
        let answer = [1, 1, 3, 4]

        XCTAssertThrowsError(
            try MastermindEvaluator.evaluate(guess, with: answer)
        )
    }
    
    func test_evaluate_throwsErrorOnDuplicateNumberGuessInput() {
        let guess = [1, 1, 3, 4]
        let answer = [1, 2, 3, 4]

        XCTAssertThrowsError(
            try MastermindEvaluator.evaluate(guess, with: answer)
        )
    }
    
    func test_evaluate_returnsZeroMisplacedCountOnCorrectGuess() throws {
        let guesses = [[1, 2, 3, 4], [3, 5, 6, 7], [8, 5, 3, 9]]
        let answers = [[1, 2, 3, 4], [3, 5, 6, 7], [8, 5, 3, 9]]
        
        try guesses.enumerated().forEach { index, guess in
            let answer = answers[index]
            
            let misplacedCount = try MastermindEvaluator.evaluate(guess, with: answer).misplacedCount
            XCTAssertEqual(misplacedCount, 0)
        }
    }
    
    func test_evaluate_returnsCorrectCountOnCorrectGuess() throws {
        let guesses = [[1, 2, 3, 4], [3, 5, 6, 7, 2], [8, 5, 3, 9, 4, 7]]
        let answers = [[1, 2, 3, 4], [3, 5, 6, 7, 2], [8, 5, 3, 9, 4, 7]]
        
        try guesses.enumerated().forEach { index, guess in
            let answer = answers[index]
            
            let correctCount = try MastermindEvaluator.evaluate(guess, with: answer).correctCount
            XCTAssertEqual(correctCount, guess.count)
        }
    }
    
    func test_evaluate_returnsNoCountsOnNonReleventGuess() throws {
        let guesses = [[1, 2, 3, 4], [3, 5, 6, 7, 2]]
        let answers = [[5, 6, 7, 8], [1, 8, 4, 9, 0]]
        
        try guesses.enumerated().forEach { index, guess in
            let answer = answers[index]
            
            let (correctCount, misplacedCount) = try MastermindEvaluator.evaluate(guess, with: answer)
            XCTAssertEqual(correctCount, 0)
            XCTAssertEqual(misplacedCount, 0)
        }
    }
    
    func test_evaluate_returnsExpectedCountsOnPartiallyCorrectGuesses() throws {
        let guesses = [[1, 2, 3, 4], [3, 5, 6, 7, 2],  [3, 5, 6, 7, 2]]
        let answers = [[5, 4, 7, 0], [1, 8, 6, 9, 0],  [5, 7, 6, 8, 0]]
        let expectedCorrectCounts = [0, 1, 1]
        let expectedMisplacedCounts = [1, 0, 2]
        
        try guesses.enumerated().forEach { index, guess in
            let answer = answers[index]
            
            let (correctCount, misplacedCount) = try MastermindEvaluator.evaluate(guess, with: answer)
            XCTAssertEqual(correctCount, expectedCorrectCounts[index])
            XCTAssertEqual(misplacedCount, expectedMisplacedCounts[index])
        }
    }
    
    // MARK: - Helpers
    
    private func lengthMismatch() -> NSError {
        MastermindEvaluator.Error.lengthMismatch as NSError
    }
}
