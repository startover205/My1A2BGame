//
//  MastermindEvaluator.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/7/20.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import Foundation

public final class MastermindEvaluator {
    public enum Error: Swift.Error {
        case lengthMismatch
        case duplicateNumber
    }

    public static func evaluate(_ guess: [Int], with answer: [Int]) throws -> (correctCount: Int, misplacedCount: Int) {
        guard guess.count == answer.count else { throw Error.lengthMismatch }
        guard guess.count == Set(guess).count else { throw Error.duplicateNumber }
        guard answer.count == Set(answer).count else { throw Error.duplicateNumber }
        
        var correctCount = 0
        var misplacedCount = 0
        
        guess.enumerated().forEach { guessIndex, guessNumber in
            answer.enumerated().forEach { answerIndex, answerNumber in
                if guessNumber == answerNumber {
                    guessIndex == answerIndex ? (correctCount += 1) : (misplacedCount += 1)
                }
            }
        }

        return (correctCount, misplacedCount)
    }
}

