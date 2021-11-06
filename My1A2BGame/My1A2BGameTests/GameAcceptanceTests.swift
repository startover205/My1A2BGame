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
        assertDisplayingWinSceneOnGameWin(game: launch().basicGame())
    }
    
    func test_onGameWin_requestsReviewOnThirdWin_basicGame() {
        assertRequestAppReviewOnThirdWin {
            $0.basicGame()
        }
    }
    
    func test_onGameLose_displayLoseScene_basicGame() {
        assertDisplayingLoseSceneOnGameLose(game: launch().basicGame(), guessChanceCount: GameVersion.basic.maxGuessCount)
    }
    
    func test_onGiveUpGame_displayLoseScene_basicGame() throws {
        try assertDisplayingLoseSceneOnUserGiveUpGame(game: launch().basicGame())
    }
    
    func test_onNoGameChanceLeft_displaysAd_basicGame() throws {
        try assertDisplayingAdOnNoGameChanceLeft(game: { adLoader in
            launch(rewardAdLoader: adLoader).basicGame()
        }, guessChanceCount: 10)
    }
    
    func test_onGameWin_displaysWinScene_advancedGame() {
        assertDisplayingWinSceneOnGameWin(game: launch().advancedGame())
    }
    
    func test_onGameWin_requestsAppReviewOnThirdWin_advancedGame() {
        assertRequestAppReviewOnThirdWin {
            $0.advancedGame()
        }
    }
    
    func test_onGameLose_displayLoseScene_advancedGame() {
        assertDisplayingLoseSceneOnGameLose(game: launch().advancedGame(), guessChanceCount: GameVersion.advanced.maxGuessCount)
    }
    
    func test_onGiveUpGame_displayLoseScene_advancedGame() throws {
        try assertDisplayingLoseSceneOnUserGiveUpGame(game: launch().advancedGame())
    }
    
    func test_onNoGameChanceLeft_displaysAd_advancedGame() throws {
        try assertDisplayingAdOnNoGameChanceLeft(game: { adLoader in
            launch(rewardAdLoader: adLoader).advancedGame()
        }, guessChanceCount: 15)
    }
    
    func test_hasFAQView() {
        let more = launch().moreController()
        
        more.simulateSelectNavigateToFAQ()
        
        XCTAssertTrue(more.navigationController?.topViewController is FAQViewController)
    }
    
    // MARK: - Helpers
    
    private func launch(userDefaults: UserDefaults = InMemoryUserDefaults(), rewardAdLoader: RewardAdLoaderStub = .null, requestReview: @escaping () -> Void = {}) -> UITabBarController {
        let sut = AppDelegate(userDefaults: userDefaults, secretGenerator: makeSecretGenerator(), rewardAdLoader: rewardAdLoader, requestReview: requestReview)
        sut.window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        sut.configureWindow()
        
        return sut.window?.rootViewController as! UITabBarController
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
    
    private final class RewardAdSpy: RewardAd {
        var capturedPresentation: ((viewController: UIViewController, handler: () -> Void))?
        
        func present(fromRootViewController rootViewController: UIViewController, userDidEarnRewardHandler: @escaping () -> Void) {
            capturedPresentation = (rootViewController, userDidEarnRewardHandler)
        }
    }
}

private extension GameAcceptanceTests {
    func assertDisplayingWinSceneOnGameWin(game: GuessNumberViewController, file: StaticString = #filePath, line: UInt = #line) {
        game.simulatePlayerGuessCorrectly()
        RunLoop.current.run(until: Date())
        
        XCTAssertNotNil(game.navigationController?.topViewController as? WinViewController, file: file, line: line)
    }
    
    func assertRequestAppReviewOnThirdWin(for game: (UITabBarController) -> GuessNumberViewController, file: StaticString = #filePath, line: UInt = #line) {
        let userDefaults = InMemoryUserDefaults()
        var reviewCallCount = 0
        let requestReview: () -> Void = {
            reviewCallCount += 1
        }
        
        game(launch(userDefaults: userDefaults, requestReview: requestReview)).simulatePlayerGuessCorrectly()
        XCTAssertEqual(reviewCallCount, 0, "Expect no request until the third win", file: file, line: line)
        
        game(launch(userDefaults: userDefaults, requestReview: requestReview)).simulatePlayerGuessCorrectly()
        XCTAssertEqual(reviewCallCount, 0, "Expect no request until the third win", file: file, line: line)
        
        game(launch(userDefaults: userDefaults, requestReview: requestReview)).simulatePlayerGuessCorrectly()
        XCTAssertEqual(reviewCallCount, 1, "Expect review request on the third win", file: file, line: line)
    }
    
    func assertDisplayingLoseSceneOnGameLose(game: GuessNumberViewController, guessChanceCount: Int, file: StaticString = #filePath, line: UInt = #line) {
        game.simulateGameLose(guessChanceCount: guessChanceCount)
        
        RunLoop.current.run(until: Date())
        
        XCTAssertNotNil(game.navigationController?.topViewController as? LoseViewController, file: file, line: line)
    }
    
    func assertDisplayingLoseSceneOnUserGiveUpGame(game: GuessNumberViewController, file: StaticString = #filePath, line: UInt = #line) throws {
        let exp = expectation(description: "wait for presentation complete")
        
        try game.simulateUserGiveUp(completion: {
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 10.0)
        
        XCTAssertNotNil(game.navigationController?.topViewController as? LoseViewController, file: file, line: line)
    }
    
    func assertDisplayingAdOnNoGameChanceLeft(game: (RewardAdLoaderStub) -> GuessNumberViewController, guessChanceCount: Int, file: StaticString = #filePath, line: UInt = #line) throws {
        let ad = RewardAdSpy()
        let game = game(RewardAdLoaderStub.init(ad: ad))
        
        for _ in 0..<guessChanceCount-1 {
            game.simulateOneWrongGuess()
        }
        RunLoop.current.run(until: Date())
        
        XCTAssertNil(game.presentedViewController as? AlertAdCountdownController, "Expect ad alert not shown until out of chance", file: file, line: line)
        
        game.simulateOneWrongGuess()
        RunLoop.current.run(until: Date())
        
        let alert = try XCTUnwrap(game.presentedViewController as? AlertAdCountdownController, "Expect ad alert shown when out of chance", file: file, line: line)
        
        let exp = expectation(description: "wait for dismissal complete")
        game.dismiss(animated: false) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
        
        alert.tapConfirmButton()
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

private extension MoreViewController {
    func simulateSelectNavigateToFAQ() {
        performSegue(withIdentifier: "faq", sender: self)
    }
}

private extension UIAlertController {
    typealias AlertHandler = @convention(block) (UIAlertAction) -> Void

    func tapButton(atIndex index: Int) {
        guard let block = actions[index].value(forKey: "handler") else { return }
        let handler = unsafeBitCast(block as AnyObject, to: AlertHandler.self)
        handler(actions[index])
    }
}

private extension UITabBarController {
    private func selectTab<T>(at index: Int) -> T {
        selectedIndex = index
        
        RunLoop.current.run(until: Date())
        
        let nav = viewControllers?[index] as? UINavigationController
        return nav?.topViewController as! T
    }
    
    func basicGame() -> GuessNumberViewController { selectTab(at: 0) }
    
    func advancedGame() -> GuessNumberViewController { selectTab(at: 1) }
    
    func moreController() -> MoreViewController { selectTab(at: 3) }
}
