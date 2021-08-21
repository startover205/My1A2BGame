//
//  GameAcceptanceTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/8/21.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import Mastermind
import MastermindiOS
@testable import My1A2BGame

class GameAcceptanceTests: XCTestCase{
    
    func test_onGameWin_displaysWinScene_basicGame() {
        let win = showWinScene(from: launchBasicGame)
        
        XCTAssertEqual(win.winMessage(), makeWinMessageForBasicGame())
        XCTAssertEqual(win.gameResultMessage(), makeGameResultMessage())
    }
    
    func test_onGameWin_displaysWinScene_advancedGame() {
        let win = showWinScene(from: launchAdvancedGame)
        
        XCTAssertEqual(win.winMessage(), makeWinMessageForAdvancedGame())
        XCTAssertEqual(win.gameResultMessage(), makeGameResultMessage())
    }
    
    // MARK: - Helpers
    
    private func launch() -> UITabBarController {
        let sut = AppDelegate()
        sut.window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        sut.configureWindow()
        
        return sut.window?.rootViewController as! UITabBarController
    }
    
    private func launchBasicGame() -> GuessNumberViewController {
        let tab = launch()
        tab.selectedIndex = 0
        
        let nav = tab.viewControllers?.first as? UINavigationController
        return nav?.topViewController as! GuessNumberViewController
    }

    private func launchAdvancedGame() -> GuessNumberViewController {
        let tab = launch()
        tab.selectedIndex = 1
        
        let nav = tab.viewControllers?[1] as? UINavigationController
        return nav?.topViewController as! GuessNumberViewController
    }

    private func showWinScene(from game: () -> (GuessNumberViewController)) -> WinViewController {
        let game = game()
        
        game.simulatePlayerWin(with: makeScore())
        RunLoop.current.run(until: Date())
        
        let nav = game.navigationController
        return nav?.topViewController as! WinViewController
    }
    
    private func makeScore() -> Score { (5, 50.0) }
    
    private func makeWinMessageForBasicGame() -> String { "4A0B!! You won!!" }
    
    private func makeWinMessageForAdvancedGame() -> String { "5A0B!! You won!!" }
    
    private func makeGameResultMessage() -> String { "You guessed 5 times" }
}

private extension GuessNumberViewController {
    func simulatePlayerWin(with score: Score){
        onWin?(score.guessCount, score.guessTime)
    }
}

private extension WinViewController {
    func winMessage() -> String? { winLabel.text }
    
    func gameResultMessage() -> String? { guessCountLabel.text }
}
