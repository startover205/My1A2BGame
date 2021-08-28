//
//  ChallengeDelegate.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/25.
//

public protocol ChallengeDelegate {
    associatedtype Hint
    associatedtype Guess
    
    func acceptGuess(with hint: Hint?, completion: @escaping (_ guess: Guess) -> Void)

    func didLose(with hint: Hint?)
    
    func didWin(with hint: Hint?)
}
