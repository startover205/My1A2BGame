//
//  FlowDelegate.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/25.
//

public protocol FlowDelegate {
    associatedtype Hint
    associatedtype Guess
    
    func acceptGuess(with hint: Hint?, completion: @escaping (_ guess: Guess) -> Void)

    func handleLose(_ hint: Hint?)
    
    func handleWin(_ hint: Hint?)
}
