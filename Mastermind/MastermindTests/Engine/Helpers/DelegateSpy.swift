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
        case replenishChance
    }
    
    private(set) var receivedMessages = [Message]()
    private var replenishCompletions = [(Int) -> Void]()
    private var guessCompletions = [(String) -> (String?, Bool)]()
    
    func acceptGuess(completion: @escaping (String) -> (hint: String?, correct: Bool)) {
        receivedMessages.append(.acceptGuess)
        guessCompletions.append(completion)
    }
    
    func didLose() {
        receivedMessages.append(.handleLose)
    }
    
    func didWin() {
        receivedMessages.append(.handleWin)
    }
    
    func replenishChance(completion: @escaping (Int) -> Void) {
        receivedMessages.append(.replenishChance)
        replenishCompletions.append(completion)
    }
    
    func completeGuess(with guess: String, at index: Int = 0) -> (String?, Bool) {
        guessCompletions[index](guess)
    }
    
    func completeReplenish(with chanceCount: Int, at index: Int = 0) {
        replenishCompletions[index](chanceCount)
    }
}
