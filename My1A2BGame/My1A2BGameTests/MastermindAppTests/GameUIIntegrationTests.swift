//
//  GameUIIntegrationTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/7/25.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
@testable import My1A2BGame
import Mastermind
import MastermindiOS
import GoogleMobileAds

class GameUIIntegrationTests: XCTestCase {
    func test_gameView_hasTitle() {
        let gameVersion = GameVersionMock()
        let sut = makeSUT(gameVersion: gameVersion)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, gameVersion.title)
    }
    
    func test_viewComponents_fadeInOnAppear() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        sut.fadeInCompoenents.forEach {
            XCTAssertTrue($0.alpha == 0)
        }
        
        sut.simulateViewAppear()
        
        sut.fadeInCompoenents.forEach {
            XCTAssertTrue($0.alpha != 0)
        }
    }
    
    func test_voicePrompt_canToggleFromView() {
        let userDefaults = UserDefaultsMock()
        let sut = makeSUT()
        sut.voicePromptViewController = VoicePromptViewController(userDefaults: userDefaults)
        let anotherSut = makeSUT()
        
        userDefaults.setVoicePromptOn()
        sut.loadViewIfNeeded()
        sut.simulateViewAppear()
        
        XCTAssertTrue(sut.voicePromptOn, "expect voice switch is on matching the user preferance")
        
        sut.simulateToggleVoicePrompt()
        anotherSut.loadViewIfNeeded()
        anotherSut.simulateViewAppear()
        
        XCTAssertFalse(anotherSut.voicePromptOn, "expect voice switch is off matching the user preferance")
    }
    
    func test_guess_rendersResult() {
        let sut = makeSUT()
        let answer = ["1", "2", "3", "4"]
        let guess1 = ["5", "2", "3", "4"]
        let guess2 = ["5", "6", "3", "4"]
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.resultMessage, "", "expected no text after loading")
        
        sut.simulateGuessWith(answer: answer, guess: guess1)
        XCTAssertEqual(sut.resultMessage, "5234          3A0B\n", "expected latest result after matching")
        
        sut.simulateGuessWith(answer: answer, guess: guess2)
        XCTAssertEqual(sut.resultMessage, "5634          2A0B\n", "expected latest result after matching")
    }
    
    func test_availableGuess_rendersWithEachGuess() {
        let sut = makeSUT(gameVersion: GameVersionMock(maxGuessCount: 3))

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: 3), "expect max guess count once view is loaded")

        sut.simulateUserInitiatedWrongGuess()
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: 2), "expect guess count minus 1 after user guess")

        sut.simulateUserInitiatedWrongGuess()
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: 1), "expect guess count minus 1 after user guess")

        sut.simulateUserInitiatedWrongGuess()
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: 0), "expect guess count minus 1 after user guess")
    }
    
    func test_restart_resetGameView() {
        let gameVersion = GameVersionMock(maxGuessCount: 1)
        let sut = makeSUT(gameVersion: gameVersion)
        
        sut.loadViewIfNeeded()
        assertThatViewIsInitialState(sut)

        sut.simulateTapHelperButton()
        XCTAssertFalse(sut.helperView.isHidden, "expect helper view to show after helper button pressed")
        sut.simulateUserInitiatedWrongGuess()
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: sut.availableGuess), "expect guess count minus 1 after user guess")
        
        sut.simulateRestartGame()
        assertThatViewIsInitialState(sut)
        
        sut.simulateUserInitiatedWrongGuess()
        XCTAssertEqual(sut.hintTextView.text, "\n", "expect empty hint text view on first guess")
    }
    
    func test_deallocation_doesNotRetain() {
        let sut = makeSUT()
        
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(sut.voicePromptViewController!)
    }
    
//    func test_endGame_showAnswerOnlyAfterResultViewIsPresented() {
//        let window = UIWindow()
//        let nav = NavigationSpy()
//        let sut = makeSUT(gameVersion: GameVersionMock(maxGuessCount: 1))
//        nav.setViewControllers([sut], animated: false)
//        nav.delegate = sut
//
//        window.rootViewController = nav
//        window.makeKeyAndVisible()
//        nav.pushCapturedControllerWithoutAnimation()
//
//        sut.loadViewIfNeeded()
//        let answer = sut.quizNumbers
//        let placeholders = answerPlaceholder(for: sut.gameVersion)
//
//        XCTAssertEqual(sut.quizLabels.map { $0.text }, placeholders, "expect showing placeholders after game start")
//
//        sut.simulateUserInitiatedWrongGuess()
//        XCTAssertEqual(sut.quizLabels.map { $0.text }, placeholders, "expect showing placeholders before showing the result controller")
//
//        nav.pushCapturedControllerWithoutAnimation()
//        XCTAssertEqual(sut.quizLabels.map { $0.text }, answer, "expect showing answer after showing the result controller")
//
//        // remove retain on sut
//        nav.setViewControllers([], animated: false)
//    }

    // MARK: Helpers
    
    private func makeSUT(gameVersion: GameVersion = GameVersionMock(), userDefaults: UserDefaults = UserDefaultsMock(), file: StaticString = #filePath, line: UInt = #line) -> GuessNumberViewController {
        let sut = GameUIComposer.gameComposedWith(gameVersion: gameVersion, userDefaults: userDefaults, adProvider: AdProviderFake(), onWin: { _, _ in })
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private var basicGameTitle: String { "Basic" }
    
    private var advancedGameTitle: String { "Advanced" }
    
    private func answerPlaceholder(for gameVersion: GameVersion) -> [String] { Array(repeating: "?", count: gameVersion.digitCount) }
    
    private final class GameVersionMock: GameVersion {
        let digitCount: Int = 4
        
        let title: String = "a title"
        
        let maxGuessCount: Int
        
        init(maxGuessCount: Int = 5) {
            self.maxGuessCount = maxGuessCount
        }
    }
    
    private func guessMessageFor(guessCount: Int) -> String {
        let format = NSLocalizedString("You can still guess %d times", tableName: nil, bundle: .init(for: GuessNumberViewController.self), value: "", comment: "")
        return String.localizedStringWithFormat(format, guessCount)
    }
    
    private func assertThatViewIsInitialState(_ sut: GuessNumberViewController, file: StaticString = #filePath, line: UInt = #line) {
        let maxGuessCount = sut.gameVersion.maxGuessCount
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: maxGuessCount), "expect max guess count once view is loaded", file: file, line: line)
        XCTAssertTrue(sut.helperView.isHidden, "expect helper view to be hidden", file: file, line: line)
        XCTAssertEqual(sut.quizLabels.map { $0.text }, answerPlaceholder(for: sut.gameVersion), "expect quiz labels showing the placeholders", file: file, line: line)
        XCTAssertEqual(sut.lastGuessLabel.text?.isEmpty, true, "expect last guess view to be empty", file: file, line: line)
        XCTAssertTrue(sut.hintTextView.text.isEmpty, "expect hint view to be empty", file: file, line: line)
        XCTAssertTrue(sut.restartButton.isHidden, "expect restart button to be hidden", file: file, line: line)
        XCTAssertFalse(sut.guessButton.isHidden, "expect guess button to be visible", file: file, line: line)
        XCTAssertFalse(sut.quitButton.isHidden, "expect quit button to be visible", file: file, line: line)
    }
    
    private class NavigationSpy: UINavigationController {
        var capturedPush: (vc: UIViewController, animated: Bool)?
        
        override func pushViewController(_ viewController: UIViewController, animated: Bool) {
            capturedPush = (viewController, animated)
        }
        
        func pushCapturedControllerWithoutAnimation() {
            guard let vc = capturedPush?.vc else { return }
            super.pushViewController(vc, animated: false)
        }
    }
    
    private final class AdProviderFake: AdProvider {
        var rewardAd: GADRewardedAd?
    }
}

private extension GuessNumberViewController {
    func simulateViewAppear() { viewWillAppear(false) }
    
    func simulateUserInitiatedWrongGuess() {
        guessButton.sendActions(for: .touchUpInside)
        
        let answer = quizNumbers
        let guess: [String] = answer.reversed()
        
        inputVC.delegate?.padDidFinishEntering(numberTexts: guess)
    }
    
    func simulateGuessWith(answer: [String], guess: [String]) {
        tryToMatchNumbers(guessTexts: guess, answerTexts: answer)
    }
    
    func simulateTapHelperButton() {
        helperBtnPressed(self)
    }
    
    var fadeInCompoenents: [UIView] { fadeOutElements }
    
    var availableGuessMessage: String? { availableGuessLabel.text }
    
    var resultMessage: String? { lastGuessLabel.text }
    
    var voicePromptOn: Bool { voicePromptViewController?.view.isOn ?? false }
    
    func simulateToggleVoicePrompt() {
        guard let voiceView = voicePromptViewController?.view else { return }
        voiceView.isOn = !voiceView.isOn
        voiceView.sendActions(for: .valueChanged)
    }
    
    func simulateUserGiveUp() {
        showLoseVCAndEndGame()
        RunLoop.current.run(until: Date())
    }
    
    func simulateRestartGame() {
        restartButton.sendActions(for: .touchUpInside)
    }
}

private extension UserDefaults {
    func setVoicePromptOn() { setValue(true, forKey: "VOICE_PROMPT") }
}
