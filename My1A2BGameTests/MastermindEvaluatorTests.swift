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
    }

    static func evaluate(_ guess: [Int], with answer: [Int]) throws {
        guard guess.count == answer.count else { throw Error.lengthMismatch }

    }
}


class MastermindEvaluatorTests: XCTestCase {
    func test_evalute_throwsLengthMismatchErrorOnMismatchLengthInputs() {
        let guess = [1, 2, 3, 4]
        let answer = [1, 2, 3, 4, 5]

        var capturedError: Error?
        do {
            try MastermindEvaluator.evaluate(guess, with: answer)
        } catch {
            capturedError = error
        }

        XCTAssertEqual(capturedError as NSError?, lengthMismatch())
    }
    
    // MARK: - Helpers
    
    private func lengthMismatch() -> NSError {
        MastermindEvaluator.Error.lengthMismatch as NSError
    }
}
