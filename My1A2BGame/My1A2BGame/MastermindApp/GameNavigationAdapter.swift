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
    
    private var gameStart = false
    
    public init(navigationController: UINavigationController, gameComposer: @escaping (GuessCompletion) -> UIViewController, winComposer: @escaping (Score) -> UIViewController, loseComposer: @escaping () -> UIViewController, delegate: ReplenishChanceDelegate) {
        self.navigationController = navigationController
        self.gameComposer = gameComposer
        self.winComposer = winComposer
        self.loseComposer = loseComposer
        self.delegate = delegate
    }
    
    public func acceptGuess(completion: @escaping GuessCompletion) {
        if !gameStart {
            gameStart = true
            
            navigationController.setViewControllers([gameComposer(completion)], animated: false)
        }
    }
    
    public func didWin() {
        let score = (0, 0.0)
        navigationController.pushViewController(winComposer(score), animated: true)
    }
    
    public func didLose() {
        navigationController.pushViewController(loseComposer(), animated: true)
    }
    
    public func replenishChance(completion: @escaping (Int) -> Void) {
        delegate.replenishChance(completion: completion)
    }
}
