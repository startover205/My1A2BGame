//
//  DigitSecretMatcher.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/30.
//

import Foundation

public struct MatchResult {
    public let bulls: Int
    public let cows: Int
    public let correct: Bool
    
    public init(bulls: Int, cows: Int, correct: Bool) {
        self.bulls = bulls
        self.cows = cows
        self.correct = correct
    }
}

public final class DigitSecretMatcher {
    private init() {}
    
    @available(*, deprecated)
    public static func match(_ guess: DigitSecret, with secret: DigitSecret) -> (hint: String, correct: Bool) {
        guard guess.content.count == secret.content.count else { return ("mismatch length", false) }
        
        var correctCount = 0
        var misplacedCount = 0
        
        guess.content.enumerated().forEach { guessIndex, guessDigit in
            secret.content.enumerated().forEach { answerIndex, answerDigit in
                if guessDigit == answerDigit {
                    guessIndex == answerIndex ? (correctCount += 1) : (misplacedCount += 1)
                }
            }
        }
        
        return ("\(correctCount)A\(misplacedCount)B", correctCount == secret.content.count)
    }
    
    public static func matchGuess(_ guess: DigitSecret, with secret: DigitSecret) -> MatchResult {
        guard guess.content.count == secret.content.count else { return .init(bulls: 0, cows: 0, correct: false) }
        
        var correctCount = 0
        var misplacedCount = 0
        
        guess.content.enumerated().forEach { guessIndex, guessDigit in
            secret.content.enumerated().forEach { answerIndex, answerDigit in
                if guessDigit == answerDigit {
                    guessIndex == answerIndex ? (correctCount += 1) : (misplacedCount += 1)
                }
            }
        }
        
        return .init(bulls: correctCount, cows: misplacedCount, correct: correctCount == secret.content.count)
    }
}
