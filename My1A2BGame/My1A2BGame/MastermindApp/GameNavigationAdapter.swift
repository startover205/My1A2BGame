//
//  GameNavigationAdapter.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/9/3.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit
import Mastermind

public typealias GuessCompletion = (_ guess: DigitSecret) -> (hint: String?, correct: Bool)

public final class GameNavigationAdapter: ChallengeDelegate {
    private let navigationController: UINavigationController
    private let gameComposer: (GuessCompletion) -> UIViewController
    private let winComposer: (Score) -> UIViewController
    private let loseComposer: () -> UIViewController
    private let delegate: ReplenishChanceDelegate
    private let currentDeviceTime: () -> TimeInterval
    
    private var gameStart = false
    private var gameStartTime: TimeInterval?
    private var guessCount = 0
    
    public init(navigationController: UINavigationController, gameComposer: @escaping (GuessCompletion) -> UIViewController, winComposer: @escaping (Score) -> UIViewController, loseComposer: @escaping () -> UIViewController, delegate: ReplenishChanceDelegate, currentDeviceTime: @escaping () -> TimeInterval) {
        self.navigationController = navigationController
        self.gameComposer = gameComposer
        self.winComposer = winComposer
        self.loseComposer = loseComposer
        self.delegate = delegate
        self.currentDeviceTime = currentDeviceTime
    }
    
    public func acceptGuess(completion: @escaping GuessCompletion) {
        if !gameStart {
            gameStart = true
            
            gameStartTime = currentDeviceTime()
            
            navigationController.setViewControllers([gameComposer(completion)], animated: false)
        }
        
        guessCount += 1
    }
    
    public func didWin() {
        let guessTime = gameStartTime == nil ? 0.0 : currentDeviceTime() - gameStartTime!
        let score = (guessCount, guessTime)
        navigationController.pushViewController(winComposer(score), animated: true)
    }
    
    public func didLose() {
        navigationController.pushViewController(loseComposer(), animated: true)
    }
    
    public func replenishChance(completion: @escaping (Int) -> Void) {
        delegate.replenishChance(completion: completion)
    }
}
