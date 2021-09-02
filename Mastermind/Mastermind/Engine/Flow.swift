//
//  Flow.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/25.
//

import Foundation

final class Flow<Delegate: ChallengeDelegate, Secret> {
    typealias Hint = Delegate.Hint
    typealias Guess = Delegate.Guess
 
    private let maxChanceCount: Int
    private let secret: Secret
    private let delegate: Delegate
    private let matchGuess: GuessMatcher<Delegate, Secret>
    
    init(maxChanceCount: Int, secret: Secret, matchGuess: @escaping GuessMatcher<Delegate, Secret>,  delegate: Delegate) {
        self.maxChanceCount = maxChanceCount
        self.secret = secret
        self.delegate = delegate
        self.matchGuess = matchGuess
    }
    
   func start() {
       delegateSecretNumberHandling(chancesLeft: maxChanceCount)
   }
    
    private func delegateSecretNumberHandling(chancesLeft: Int) {
        if chancesLeft > 0 {
            delegate.acceptGuess(completion: guess(for: secret, chancesLeft: chancesLeft))
        } else {
            delegate.replenishChance(completion: didReplenishChance())
        }
    }
    
    private func guess(for secret: Secret, chancesLeft: Int) -> (Guess) -> (hint: Hint?, correct: Bool) {
        return { [weak self] guess in
            guard let self = self else { return (nil, false) }
            
            let result = self.matchGuess(guess, secret)
            
            if result.correct {
                self.delegate.didWin()
            } else {
                self.delegateSecretNumberHandling(chancesLeft: chancesLeft-1)
            }
            
            return result
        }
    }
    
    private func didReplenishChance() -> (_ chanceCount: Int) -> Void {
        return { [weak self] chanceCount in
            guard let self = self else { return }
            
            if chanceCount > 0 {
                self.delegateSecretNumberHandling(chancesLeft: chanceCount)
            } else {
                self.delegate.didLose()
            }
            
        }
    }
}
