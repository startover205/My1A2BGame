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
        let win = showWinScene(from: launchBasicGame, digitCount: 4)
        
        XCTAssertEqual(win.winMessage(), makeWinMessageForBasicGame())
        XCTAssertEqual(win.gameResultMessage(), makeGameResultMessage())
    }
    
    func test_onGameLose_displayLoseScene_basicGame() {
        let sut = launchBasicGame()
        
        sut.simulateGameLose()
        
        RunLoop.current.run(until: Date())
        
        XCTAssertNotNil(sut.navigationController?.topViewController as? LoseViewController)
    }
    
    func test_onGiveUpGame_displayLoseScene_basicGame() {
        let sut = launchBasicGame()

        let exp = expectation(description: "wait for request")
        
        try? sut.simulateUserGiveUp(completion: {
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 2)
        
        XCTAssertNotNil(sut.navigationController?.topViewController as? LoseViewController)
    }
    
    func test_onGameWin_displaysWinScene_advancedGame() {
        let win = showWinScene(from: launchAdvancedGame, digitCount: 5)
        
        XCTAssertEqual(win.winMessage(), makeWinMessageForAdvancedGame())
        XCTAssertEqual(win.gameResultMessage(), makeGameResultMessage())
    }
    
    func test_onGameLose_displayLoseScene_advancedGame() {
        let sut = launchAdvancedGame()
        
        sut.simulateGameLose()
        
        RunLoop.current.run(until: Date())
        
        XCTAssertNotNil(sut.navigationController?.topViewController as? LoseViewController)
    }
    
    func test_onGiveUpGame_displayLoseScene_advancedGame() {
        let sut = launchAdvancedGame()

        let exp = expectation(description: "wait for request")
        
        try? sut.simulateUserGiveUp(completion: {
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 2)
        
        XCTAssertNotNil(sut.navigationController?.topViewController as? LoseViewController)
    }
    
    // MARK: - Helpers
    
    private func launch() -> UITabBarController {
        let sut = AppDelegate(secretGenerator: makeSecretGenerator())
        sut.window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        sut.configureWindow()
        
        return sut.window?.rootViewController as! UITabBarController
    }
    
    private func launchBasicGame() -> GuessNumberViewController {
        let tab = launch()
        tab.selectedIndex = 0
        
        RunLoop.current.run(until: Date())
        
        let nav = tab.viewControllers?.first as? UINavigationController
        return nav?.topViewController as! GuessNumberViewController
    }

    private func launchAdvancedGame() -> GuessNumberViewController {
        let tab = launch()
        tab.selectedIndex = 1
        
        RunLoop.current.run(until: Date())
        
        let nav = tab.viewControllers?[1] as? UINavigationController
        return nav?.topViewController as! GuessNumberViewController
    }

    private func showWinScene(from game: () -> (GuessNumberViewController), digitCount: Int) -> WinViewController {
        let game = game()
        
        RunLoop.current.run(until: Date())
        
        game.simulatePlayerWin(with: makeGuess(digitCount: digitCount))
        
        RunLoop.current.run(until: Date())
        
        let nav = game.navigationController
        return nav?.topViewController as! WinViewController
    }
    
    private func makeSecretGenerator() -> (Int) -> DigitSecret {
        return { digitCount in
            
            var digits = [Int]()
            for i in 0..<digitCount {
                digits.append(i)
            }
            
            return DigitSecret(digits: digits)!
        }
    }
    
    private func makeGuess(digitCount: Int) -> DigitSecret { makeSecretGenerator()(digitCount) }
    
    private func makeWinMessageForBasicGame() -> String { "4A0B!! You won!!" }
    
    private func makeWinMessageForAdvancedGame() -> String { "5A0B!! You won!!" }
    
    private func makeGameResultMessage() -> String { "You guessed 1 time" }
}

private extension GuessNumberViewController {
    func simulatePlayerWin(with guess: DigitSecret){
        tryToMatchNumbers(guessTexts: guess.content.compactMap(String.init))
    }
    
    func simulateGameLose() {
        for _ in 0..<availableGuess {
            inputVC.delegate?.padDidFinishEntering(numberTexts: [])
        }
    }
    
    func simulateUserGiveUp(completion: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) throws {
        quitButton.sendActions(for: .touchUpInside)

        let alert = try XCTUnwrap(presentedViewController as? UIAlertController, file: file, line: line)

        dismiss(animated: false, completion: {
            alert.tapButton(atIndex: 0)

            completion()
        })
    }
}

private extension WinViewController {
    func winMessage() -> String? { winLabel.text }
    
    func gameResultMessage() -> String? { guessCountLabel.text }
}

private extension UIAlertController {
    typealias AlertHandler = @convention(block) (UIAlertAction) -> Void

    func tapButton(atIndex index: Int) {
        guard let block = actions[index].value(forKey: "handler") else { return }
        let handler = unsafeBitCast(block as AnyObject, to: AlertHandler.self)
        handler(actions[index])
    }
}
