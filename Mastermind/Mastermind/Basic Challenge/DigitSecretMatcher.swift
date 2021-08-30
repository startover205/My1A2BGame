//
//  DigitSecretMatcher.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/30.
//

import Foundation

public final class DigitSecretMatcher {
    private init() {}
    
    public static func match(_ guess: FourDigitSecret, with secret: FourDigitSecret) -> (hint: String, correct: Bool) {
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
}
