//
//  MastermindEvaluatorTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/7/20.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest

public final class MastermindEvaluator {
    public enum Error: Swift.Error {
        case lengthMismatch
        case duplicateNumber
    }

    static func evaluate(_ guess: [Int], with answer: [Int]) throws -> (correctCount: Int, misplacedCount: Int) {
        guard guess.count == answer.count else { throw Error.lengthMismatch }
        guard guess.count == Set(guess).count else { throw Error.duplicateNumber }
        guard answer.count == Set(answer).count else { throw Error.duplicateNumber }


        return (0, 0)
    }
}


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
    
    // MARK: - Helpers
    
    private func lengthMismatch() -> NSError {
        MastermindEvaluator.Error.lengthMismatch as NSError
    }
}
