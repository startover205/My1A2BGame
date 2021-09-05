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
        let gameVersion = makeGameVersion()
        let sut = makeSUT(gameVersion: gameVersion)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, gameVersion.title)
    }
    
    func test_viewComponents_fadeInOnAppear() {
        let sut = makeSUT(animate: { _, animations, _ in
            animations()
        })
        
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
        let answer = ["1", "2", "3", "4"]
        let secret = DigitSecret(digits: answer.compactMap(Int.init))!
        let guess1 = ["5", "2", "3", "4"]
        let guess2 = ["5", "6", "3", "4"]
        let sut = makeSUT(secret: secret) { guess in
            DigitSecretMatcher.match(guess, with: secret)
        }
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.resultMessage, "", "expected no text after loading")
        
        sut.simulateGuess(with: guess1)
        XCTAssertEqual(sut.resultMessage, "5234          3A0B\n", "expected latest result after matching")
        
        sut.simulateGuess(with: guess2)
        XCTAssertEqual(sut.resultMessage, "5634          2A0B\n", "expected latest result after matching")
    }
    
    func test_availableGuess_rendersWithEachGuess() {
        let sut = makeSUT(gameVersion: makeGameVersion(maxGuessCount: 3), guessCompletion: { guess in
            (nil, false)
        })

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: 3), "expect max guess count once view is loaded")

        sut.simulateUserInitiateGuess()
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: 2), "expect guess count minus 1 after user guess")

        sut.simulateUserInitiateGuess()
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: 1), "expect guess count minus 1 after user guess")

        sut.simulateUserInitiateGuess()
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: 0), "expect guess count minus 1 after user guess")
    }
    
    func test_restart_notifiesRestartHandler() {
        var restartCallCount = 0
        let sut = makeSUT(onRestart: {
            restartCallCount += 1
        })
        
        sut.loadViewIfNeeded()
        sut.simulateUserRestartGame()
        
        XCTAssertEqual(restartCallCount, 1)
    }
    
    func test_deallocation_doesNotRetain() {
        let sut = makeSUT()
        
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(sut.voicePromptViewController!)
    }
    
    func test_helperView_showsByTogglingHelperButton() {
        let sut = makeSUT(animate: { _, _, completion in
            completion?(true)
        })

        sut.loadViewIfNeeded()

        XCTAssertFalse(sut.showingHelperView, "Expect helper view to be hidden upon view load")

        sut.simulateTapHelperButton()

        XCTAssertTrue(sut.showingHelperView, "Expect helper view to be shown when helper button pressed")

        sut.simulateTapHelperButton()

        XCTAssertFalse(sut.showingHelperView, "Expect helper view to be hidden again when user toggle helper button")
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
    
    private func makeSUT(gameVersion: GameVersion = .basic, userDefaults: UserDefaults = UserDefaultsMock(), secret: DigitSecret = DigitSecret(digits: [])!, guessCompletion: @escaping GuessCompletion = { _ in (nil, false)}, onRestart: @escaping () -> Void = {}, animate: @escaping Animate = { _, _, _ in }, file: StaticString = #filePath, line: UInt = #line) -> GuessNumberViewController {
        let sut = GameUIComposer.gameComposedWith(gameVersion: gameVersion, userDefaults: userDefaults, loader: RewardAdLoaderFake(), secret: secret, onRestart: onRestart, animate: animate)
        sut.guessCompletion = guessCompletion
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private var basicGameTitle: String { "Basic" }
    
    private var advancedGameTitle: String { "Advanced" }
    
    private func answerPlaceholder(for digitCount: Int) -> [String] { Array(repeating: "?", count: digitCount) }
    
    private func makeGameVersion(maxGuessCount: Int = 1) -> GameVersion {
        GameVersion(digitCount: 1, title: "a title", maxGuessCount: maxGuessCount)
    }
    
    private func guessMessageFor(guessCount: Int) -> String {
        let format = NSLocalizedString("You can still guess %d times", tableName: nil, bundle: .init(for: GuessNumberViewController.self), value: "", comment: "")
        return String.localizedStringWithFormat(format, guessCount)
    }
    
    private func assertThatViewIsInitialState(_ sut: GuessNumberViewController, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: sut.availableGuess), "expect showing available guess count once view is loaded", file: file, line: line)
        XCTAssertFalse(sut.showingHelperView, "expect helper view to be hidden", file: file, line: line)
        XCTAssertEqual(sut.quizLabelViewController?.quizLabels.map { $0.text }, answerPlaceholder(for: sut.quizLabelViewController.answer.count), "expect quiz labels showing the placeholders", file: file, line: line)
        XCTAssertEqual(sut.hintViewController.hintLabel.text?.isEmpty, true, "expect last guess view to be empty", file: file, line: line)
        XCTAssertTrue(sut.hintViewController.hintTextView.text.isEmpty, "expect hint view to be empty", file: file, line: line)
        XCTAssertTrue(sut.restartButton.isHidden, "expect restart button to be hidden", file: file, line: line)
        XCTAssertFalse(sut.guessButton.isHidden, "expect guess button to be visible", file: file, line: line)
        XCTAssertFalse(sut.quitButton.isHidden, "expect quit button to be visible", file: file, line: line)
    }
    
    private final class RewardAdLoaderFake: RewardAdLoader {
        var rewardAd: GADRewardedAd?
    }
}

private extension GuessNumberViewController {
    var fadeInCompoenents: [UIView] { fadeOutViews }
    
    var availableGuessMessage: String? { availableGuessLabel.text }
    
    var resultMessage: String? { hintViewController.hintLabel.text }
    
    var voicePromptOn: Bool { voicePromptViewController?.view.isOn ?? false }
    
    var showingHelperView: Bool {
        if let helperView = helperViewController?.helperBoardView {
            return !helperView.isHidden
        } else {
            return false
        }
    }
    
    func simulateViewAppear() { viewWillAppear(false) }
    
    func simulateUserInitiateGuess() {
        inputVC.delegate?.padDidFinishEntering(numberTexts: ["1", "2", "3", "4"])
    }
    
    func simulateGuess(with guess: [String]) {
        tryToMatchNumbers(guessTexts: guess)
    }
    
    func simulateTapHelperButton() {
        helperViewController?.helperBtnPressed(self)
    }
    
    func simulateToggleVoicePrompt() {
        guard let voiceView = voicePromptViewController?.view else { return }
        voiceView.isOn = !voiceView.isOn
        voiceView.sendActions(for: .valueChanged)
    }
    
    func simulateUserGiveUp() {
        showLoseVCAndEndGame()
        RunLoop.current.run(until: Date())
    }
    
    func simulateUserRestartGame() {
        restartButton.sendActions(for: .touchUpInside)
    }
}

private extension UserDefaults {
    func setVoicePromptOn() { setValue(true, forKey: "VOICE_PROMPT") }
}
