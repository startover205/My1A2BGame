//
//  Flow.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/25.
//

import Foundation

typealias GuessMatcher = (_ guess: String, _ secretNumber: String) -> (hint: String?, correct: Bool)

final class Flow {
    internal init(maxChanceCount: Int, secretNumber: String, matchGuess: @escaping GuessMatcher,  delegate: FlowDelegate) {
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
    var delegate: FlowDelegate
    let matchGuess: GuessMatcher
    
    private func delegateSecretNumberHandling(chancesLeft: Int, hint: String?) {
        if chancesLeft > 0 {
            delegate.acceptGuess(with: hint, completion: guess(for: secretNumber, chancesLeft: chancesLeft))
        } else {
            delegate.handleLose(hint)
        }
    }
    
    private func guess(for secretNumber: String, chancesLeft: Int) -> (String) -> Void {
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
    func acceptGuess(with hint: String?, completion: @escaping (_ guess: String) -> Void)

    func handleLose(_ hint: String?)
    
    func handleWin(_ hint: String?)
}
