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
        let win = showWinScene(from: launchBasicGame(rewardAdLoader: .null), digitCount: 4)
        assertDisplayingWinSceneOnGameWin(win: win, winMessage: makeWinMessageForBasicGame())
    }
    
    func test_onGameLose_displayLoseScene_basicGame() {
        assertDisplayingLoseSceneOnGameLose(game: launchBasicGame(rewardAdLoader: .null))
    }
    
    func test_onGiveUpGame_displayLoseScene_basicGame() {
        assertDisplayingLoseSceneOnUserGiveUpGame(game: launchBasicGame(rewardAdLoader: .null))
    }
    
    func test_onNoGameChanceLeft_displaysAd_basicGame() {
        assertDisplayingAdOnNoGameChanceLeft(game: launchBasicGame)
    }
    
    func test_onGameWin_displaysWinScene_advancedGame() {
        let win = showWinScene(from: launchAdvancedGame(rewardAdLoader: .null), digitCount: 5)
        assertDisplayingWinSceneOnGameWin(win: win, winMessage: makeWinMessageForAdvancedGame())
    }
    
    func test_onGameLose_displayLoseScene_advancedGame() {
        assertDisplayingLoseSceneOnGameLose(game: launchAdvancedGame(rewardAdLoader: .null))
    }
    
    func test_onGiveUpGame_displayLoseScene_advancedGame() {
        assertDisplayingLoseSceneOnUserGiveUpGame(game: launchAdvancedGame(rewardAdLoader: .null))
    }
    
    func test_onNoGameChanceLeft_displaysAd_advancedGame() {
        assertDisplayingAdOnNoGameChanceLeft(game: launchAdvancedGame)
    }
    
    // MARK: - Helpers
    
    private func launch(rewardAdLoader: RewardAdLoaderStub) -> UITabBarController {
        let sut = AppDelegate(secretGenerator: makeSecretGenerator(), rewardAdLoader: rewardAdLoader)
        sut.window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        sut.configureWindow()
        
        return sut.window?.rootViewController as! UITabBarController
    }
    
    private func launchBasicGame(rewardAdLoader: RewardAdLoaderStub) -> GuessNumberViewController {
        let tab = launch(rewardAdLoader: rewardAdLoader)
        tab.selectedIndex = 0
        
        RunLoop.current.run(until: Date())
        
        let nav = tab.viewControllers?.first as? UINavigationController
        return nav?.topViewController as! GuessNumberViewController
    }

    private func launchAdvancedGame(rewardAdLoader: RewardAdLoaderStub) -> GuessNumberViewController {
        let tab = launch(rewardAdLoader: rewardAdLoader)
        tab.selectedIndex = 1
        
        RunLoop.current.run(until: Date())
        
        let nav = tab.viewControllers?[1] as? UINavigationController
        return nav?.topViewController as! GuessNumberViewController
    }
    
    private func showWinScene(from game: GuessNumberViewController, digitCount: Int) -> WinViewController {
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
    
    private final class RewardAdSpy: RewardAd {
        var capturedPresentation: ((viewController: UIViewController, handler: () -> Void))?
        
        func present(fromRootViewController rootViewController: UIViewController, userDidEarnRewardHandler: @escaping () -> Void) {
            capturedPresentation = (rootViewController, userDidEarnRewardHandler)
        }
    }
}

private extension GameAcceptanceTests {
    func assertDisplayingWinSceneOnGameWin(win: WinViewController, winMessage: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(win.winMessage(), winMessage, file: file, line: line)
        XCTAssertEqual(win.gameResultMessage(), makeGameResultMessage(), file: file, line: line)
    }
    
    func assertDisplayingLoseSceneOnGameLose(game: GuessNumberViewController, file: StaticString = #filePath, line: UInt = #line) {
        game.simulateGameLose()
        
        XCTAssertNotNil(game.navigationController?.topViewController as? LoseViewController, file: file, line: line)
    }
    
    func assertDisplayingLoseSceneOnUserGiveUpGame(game: GuessNumberViewController, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for presentation complete")
        
        try? game.simulateUserGiveUp(completion: {
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 10.0)
        
        XCTAssertNotNil(game.navigationController?.topViewController as? LoseViewController, file: file, line: line)
    }
    
    func assertDisplayingAdOnNoGameChanceLeft(game: (RewardAdLoaderStub) -> GuessNumberViewController) {
        let ad = RewardAdSpy()
        let game = game(RewardAdLoaderStub.init(ad: ad))
        
        let exp = expectation(description: "wait for presentation complete")
        
        try? game.simulateOutOfChances() {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10.0)
        
        XCTAssertEqual(ad.capturedPresentation?.viewController, game)
    }
}

private extension GuessNumberViewController {
    func simulatePlayerWin(with guess: DigitSecret){
        tryToMatchNumbers(guessTexts: guess.content.compactMap(String.init))
    }
    
    func simulateGameLose() {
        for _ in 0..<availableGuess {
            inputVC.delegate?.padDidFinishEntering(numberTexts: [])
        }
        
        RunLoop.current.run(until: Date())
    }
    
    func simulateUserGiveUp(completion: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) throws {
        quitButton.sendActions(for: .touchUpInside)

        let alert = try XCTUnwrap(presentedViewController as? UIAlertController, file: file, line: line)

        dismiss(animated: false, completion: {
            alert.tapButton(atIndex: 0)

            completion()
        })
    }
    
    func simulateOutOfChances(completion: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) throws {
        for _ in 0..<availableGuess {
            inputVC.delegate?.padDidFinishEntering(numberTexts: [])
        }
        
        RunLoop.current.run(until: Date())
        
        let alert = try XCTUnwrap(presentedViewController as? AlertAdCountdownController, file: file, line: line)

        dismiss(animated: false, completion: {
            alert.tapConfirmButton()

            completion()
        })
        
        RunLoop.current.run(until: Date())
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

private class RewardAdLoaderStub: RewardAdLoader {
    private let ad: RewardAd?
    
    var rewardAd: RewardAd? { ad }
    
    init(ad: RewardAd?) {
        self.ad = ad
    }
}

private extension RewardAdLoaderStub {
    static var null: RewardAdLoaderStub {
        .init(ad: nil)
    }
    
    static func providing(_ stub: RewardAd) -> RewardAdLoaderStub {
        .init(ad: stub)
    }
}
