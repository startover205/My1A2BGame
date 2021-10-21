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
        let win = showWinScene(from: launchBasicGame())
        assertDisplayingWinSceneOnGameWin(win: win, winMessage: makeWinMessageForBasicGame())
    }
    
    func test_onGameWin_requestsReviewOnThirdWin_basicGame() {
        let userDefaults = UserDefaultsMock()
        var reviewCallCount = 0
        let requestReview: () -> Void = {
            reviewCallCount += 1
        }
        
        let _ = showWinScene(from: launchBasicGame(userDefaults: userDefaults, requestReview: requestReview))
        XCTAssertEqual(reviewCallCount, 0, "Expect no request until the third win")
        
        let _ = showWinScene(from: launchBasicGame(userDefaults: userDefaults, requestReview: requestReview))
        XCTAssertEqual(reviewCallCount, 0, "Expect no request until the third win")
        
        let _ = showWinScene(from: launchBasicGame(userDefaults: userDefaults, requestReview: requestReview))
        XCTAssertEqual(reviewCallCount, 1, "Expect review request on the third win")
    }
    
    func test_onGameLose_displayLoseScene_basicGame() {
        assertDisplayingLoseSceneOnGameLose(game: launchBasicGame(), guessChanceCount: GameVersion.basic.maxGuessCount)
    }
    
    func test_onGiveUpGame_displayLoseScene_basicGame() {
        assertDisplayingLoseSceneOnUserGiveUpGame(game: launchBasicGame())
    }
    
    func test_onNoGameChanceLeft_displaysAd_basicGame() {
        assertDisplayingAdOnNoGameChanceLeft(game: { adLoader in
            launchBasicGame(rewardAdLoader: adLoader)
        }, guessChanceCount: 10)
    }
    
    func test_onGameWin_displaysWinScene_advancedGame() {
        let win = showWinScene(from: launchAdvancedGame())
        assertDisplayingWinSceneOnGameWin(win: win, winMessage: makeWinMessageForAdvancedGame())
    }
    
    func test_onGameWin_requestsAppReviewOnThirdWin_advancedGame() {
        let userDefaults = UserDefaultsMock()
        var reviewCallCount = 0
        let requestReview: () -> Void = {
            reviewCallCount += 1
        }
        
        let _ = showWinScene(from: launchAdvancedGame(userDefaults: userDefaults, requestReview: requestReview))
        XCTAssertEqual(reviewCallCount, 0, "Expect no request until the third win")
        
        let _ = showWinScene(from: launchAdvancedGame(userDefaults: userDefaults,requestReview: requestReview))
        XCTAssertEqual(reviewCallCount, 0, "Expect no request until the third win")
        
        let _ = showWinScene(from: launchAdvancedGame(userDefaults: userDefaults,requestReview: requestReview))
        XCTAssertEqual(reviewCallCount, 1, "Expect review request on the third win")
    }
    
    func test_onGameLose_displayLoseScene_advancedGame() {
        assertDisplayingLoseSceneOnGameLose(game: launchAdvancedGame(), guessChanceCount: GameVersion.advanced.maxGuessCount)
    }
    
    func test_onGiveUpGame_displayLoseScene_advancedGame() {
        assertDisplayingLoseSceneOnUserGiveUpGame(game: launchAdvancedGame())
    }
    
    func test_onNoGameChanceLeft_displaysAd_advancedGame() {
        assertDisplayingAdOnNoGameChanceLeft(game: { adLoader in
            launchAdvancedGame(rewardAdLoader: adLoader)
        }, guessChanceCount: 15)
    }
    
    // MARK: - Helpers
    
    private func launch(userDefaults: UserDefaults, rewardAdLoader: RewardAdLoaderStub, requestReview: @escaping () -> Void) -> UITabBarController {
        let sut = AppDelegate(userDefaults: userDefaults, secretGenerator: makeSecretGenerator(), rewardAdLoader: rewardAdLoader, requestReview: requestReview)
        sut.window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        sut.configureWindow()
        
        return sut.window?.rootViewController as! UITabBarController
    }
    
    private func launchBasicGame(userDefaults: UserDefaults = UserDefaultsMock(), rewardAdLoader: RewardAdLoaderStub = .null, requestReview: @escaping () -> Void = {}) -> GuessNumberViewController {
        let tab = launch(userDefaults: userDefaults, rewardAdLoader: rewardAdLoader, requestReview: requestReview)
        tab.selectedIndex = 0
        
        RunLoop.current.run(until: Date())
        
        let nav = tab.viewControllers?.first as? UINavigationController
        return nav?.topViewController as! GuessNumberViewController
    }

    private func launchAdvancedGame(userDefaults: UserDefaults = UserDefaultsMock(), rewardAdLoader: RewardAdLoaderStub = .null, requestReview: @escaping () -> Void = {}) -> GuessNumberViewController {
        let tab = launch(userDefaults: userDefaults, rewardAdLoader: rewardAdLoader, requestReview: requestReview)
        tab.selectedIndex = 1
        
        RunLoop.current.run(until: Date())
        
        let nav = tab.viewControllers?[1] as? UINavigationController
        return nav?.topViewController as! GuessNumberViewController
    }
    
    private func showWinScene(from game: GuessNumberViewController) -> WinViewController {
        RunLoop.current.run(until: Date())
        
        game.simulatePlayerGuessCorrectly()
        
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
    
    private final class ReplenishChanceDelegateSpy: ReplenishChanceDelegate {
        private(set) var capturedCompletions = [(Int) -> Void]()
        
        func replenishChance(completion: @escaping (Int) -> Void) {
            capturedCompletions.append(completion)
        }
    }
    
    private final class AppReviewControllerSpy: AppReviewController {
        func askForReviewIfAppropriate() {
        }
    }
}

private extension GameAcceptanceTests {
    func assertDisplayingWinSceneOnGameWin(win: WinViewController, winMessage: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(win.winMessage(), winMessage, file: file, line: line)
        XCTAssertEqual(win.gameResultMessage(), makeGameResultMessage(), file: file, line: line)
    }
    
    func assertDisplayingLoseSceneOnGameLose(game: GuessNumberViewController, guessChanceCount: Int, file: StaticString = #filePath, line: UInt = #line) {
        game.simulateGameLose(guessChanceCount: guessChanceCount)
        
        RunLoop.current.run(until: Date())
        
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
    
    func assertDisplayingAdOnNoGameChanceLeft(game: (RewardAdLoaderStub) -> GuessNumberViewController, guessChanceCount: Int, file: StaticString = #filePath, line: UInt = #line) {
        let ad = RewardAdSpy()
        let game = game(RewardAdLoaderStub.init(ad: ad))
        
        for _ in 0..<guessChanceCount-1 {
            game.simulateOneWrongGuess()
        }
        RunLoop.current.run(until: Date())
        
        XCTAssertNil(game.presentedViewController as? AlertAdCountdownController, "Expect ad alert not shown until out of chance", file: file, line: line)
        
        game.simulateOneWrongGuess()
        RunLoop.current.run(until: Date())
        
        let alert = try? XCTUnwrap(game.presentedViewController as? AlertAdCountdownController, "Expect ad alert shown when out of chance", file: file, line: line)
        
        let exp = expectation(description: "wait for dismissal complete")
        game.dismiss(animated: false) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
        
        alert?.tapConfirmButton()
        RunLoop.current.run(until: Date())

        XCTAssertNotNil(ad.capturedPresentation, file: file, line: line)
    }
}

private extension GuessNumberViewController {
    private var inputDelegate: NumberInputViewControllerDelegate? { delegate as? GamePresentationAdapter }
    
    func simulatePlayerGuessCorrectly() {
        inputDelegate?.numberInputViewController(NumberInputViewController(), didFinishEntering: quizLabelViewController.answer.compactMap(String.init))
    }
    
    func simulateGameLose(guessChanceCount: Int) {
        let inputVCFake = NumberInputViewController()
        for _ in 0..<guessChanceCount {
            inputDelegate?.numberInputViewController(inputVCFake, didFinishEntering: [])
        }
        
        RunLoop.current.run(until: Date())
    }
    
    func simulateUserGiveUp(completion: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) throws {
        giveUpButton.sendActions(for: .touchUpInside)

        let alert = try XCTUnwrap(presentedViewController as? UIAlertController, file: file, line: line)

        dismiss(animated: false, completion: {
            alert.tapButton(atIndex: 0)

            completion()
        })
    }
    
    func simulateOneWrongGuess() {
        inputDelegate?.numberInputViewController(NumberInputViewController(), didFinishEntering: [])
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
