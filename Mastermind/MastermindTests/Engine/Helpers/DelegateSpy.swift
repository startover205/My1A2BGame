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
    }
    
    private(set) var receivedMessages = [Message]()
    var completions = [(String) -> Void]()
    
    func acceptGuess(completion: @escaping (String) -> Void) {
        receivedMessages.append(.acceptGuess)
        completions.append(completion)
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
}
