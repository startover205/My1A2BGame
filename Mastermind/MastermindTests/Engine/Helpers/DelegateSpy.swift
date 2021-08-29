//
//  DelegateSpy.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/26.
//

import Foundation
import Mastermind

final class DelegateSpy: ChallengeDelegate {
    enum Message: Equatable {
        case acceptGuess
        case handleLose
        case handleWin
        case showHint(_ hint: String?)
        case replenishChance
    }
    
    private(set) var receivedMessages = [Message]()
    private var replenishCompletions = [(Int) -> Void]()
    private var guessCompletions = [(String) -> Void]()
    
    func acceptGuess(completion: @escaping (String) -> Void) {
        receivedMessages.append(.acceptGuess)
        guessCompletions.append(completion)
    }
    
    func didLose() {
        receivedMessages.append(.handleLose)
    }
    
    func didWin() {
        receivedMessages.append(.handleWin)
    }
    
    func showHint(_ hint: String?) {
        receivedMessages.append(.showHint(hint))
    }
    
    func replenishChance(completion: @escaping (Int) -> Void) {
        receivedMessages.append(.replenishChance)
        replenishCompletions.append(completion)
    }
    
    func completeGuess(with guess: String, at index: Int = 0) {
        guessCompletions[index](guess)
    }
    
    func completeReplenish(with chanceCount: Int, at index: Int = 0) {
        replenishCompletions[index](chanceCount)
    }
}
