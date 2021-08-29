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
       delegateSecretNumberHandling(chancesLeft: maxChanceCount, hint: nil)
   }
    
    private func delegateSecretNumberHandling(chancesLeft: Int, hint: Hint?) {
        if chancesLeft > 0 {
            delegate.acceptGuess(with: hint, completion: guess(for: secret, chancesLeft: chancesLeft))
        } else {
            delegate.didLose(with: hint)
        }
    }
    
    private func guess(for secret: Secret, chancesLeft: Int) -> (Guess) -> Void {
        return { [weak self] guess in
            guard let self = self else { return }
            
            let result = self.matchGuess(guess, secret)
            
            if result.correct {
                self.delegate.didWin(with: result.hint)
            } else {
                self.delegateSecretNumberHandling(chancesLeft: chancesLeft-1, hint: result.hint)
            }
        }
    }
}
