//
//  DelegateSpy.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/26.
//

import Foundation
import Mastermind

final class DelegateSpy: FlowDelegate {
    enum Message: Equatable {
        case acceptGuess(_ hint: String?)
        case handleLose(_ hint: String?)
        case handleWin(_ hint: String?)
    }
    
    private(set) var receivedMessages = [Message]()
    var completions = [(String) -> Void]()
    
    func acceptGuess(with hint: String?, completion: @escaping (String) -> Void) {
        receivedMessages.append(.acceptGuess(hint))
        completions.append(completion)
    }
    
    func handleLose(_ hint: String?) {
        receivedMessages.append(.handleLose(hint))
    }
    
    func handleWin(_ hint: String?) {
        receivedMessages.append(.handleWin(hint))
    }
}
