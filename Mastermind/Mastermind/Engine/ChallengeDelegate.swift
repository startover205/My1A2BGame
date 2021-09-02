//
//  ChallengeDelegate.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/25.
//

public protocol ChallengeDelegate {
    associatedtype Hint
    associatedtype Guess
    
    func acceptGuess(completion: @escaping (_ guess: Guess) -> (hint: Hint?, correct: Bool))

    func didLose()
    
    func didWin()
    
    func replenishChance(completion: @escaping (Int) -> Void)
}
