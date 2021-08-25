//
//  Flow.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/25.
//

import Foundation

typealias GuessMatcher<Delegate: FlowDelegate> = (_ guess: Delegate.Guess, _ secretNumber: String) -> (hint: Delegate.Hint?, correct: Bool)

final class Flow<Delegate: FlowDelegate> {
    typealias Hint = Delegate.Hint
    typealias Guess = Delegate.Guess
    
    internal init(maxChanceCount: Int, secretNumber: String, matchGuess: @escaping GuessMatcher<Delegate>,  delegate: Delegate) {
        self.maxChanceCount = maxChanceCount
        self.secretNumber = secretNumber
        self.delegate = delegate
        self.matchGuess = matchGuess
    }
    
    func start() {
        delegateSecretNumberHandling(chancesLeft: maxChanceCount, hint: nil)
    }
    
    var maxChanceCount: Int
    var secretNumber: String
    var delegate: Delegate
    let matchGuess: GuessMatcher<Delegate>
    
    private func delegateSecretNumberHandling(chancesLeft: Int, hint: Hint?) {
        if chancesLeft > 0 {
            delegate.acceptGuess(with: hint, completion: guess(for: secretNumber, chancesLeft: chancesLeft))
        } else {
            delegate.handleLose(hint)
        }
    }
    
    private func guess(for secretNumber: String, chancesLeft: Int) -> (Guess) -> Void {
        return { [weak self] guess in
            guard let self = self else { return }
            
            let result = self.matchGuess(guess, secretNumber)
            
            if result.correct {
                self.delegate.handleWin(result.hint)
            } else {
                self.delegateSecretNumberHandling(chancesLeft: chancesLeft-1, hint: result.hint)
            }
        }
    }
}

protocol FlowDelegate {
    associatedtype Hint
    associatedtype Guess
    
    func acceptGuess(with hint: Hint?, completion: @escaping (_ guess: Guess) -> Void)

    func handleLose(_ hint: Hint?)
    
    func handleWin(_ hint: Hint?)
}
