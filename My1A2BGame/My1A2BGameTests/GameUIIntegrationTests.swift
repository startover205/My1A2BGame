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
import AVFoundation

class GameUIIntegrationTests: XCTestCase {
    func test_gameView_hasTitle() {
        let sut = makeSUT(title: "a title")
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, "a title")
    }
    
    func test_gameScene_isLocalized() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        let viewModel = GamePresenter.sceneViewModel
        XCTAssertEqual(sut.guessHistoryViewTitle(), viewModel.guessHistoryViewTitle)
        XCTAssertEqual(sut.guessButtonTitle(), viewModel.guessAction)
        XCTAssertEqual(sut.giveUpButtonTitle(), viewModel.giveUpAction)
        XCTAssertEqual(sut.restartButtonTitle(), viewModel.restartAction)
    }
    
    func test_viewComponents_fadeInOnAppear() {
        let sut = makeSUT(animate: { _, animations, _ in
            animations()
        })
        
        sut.loadViewIfNeeded()
        sut.fadeInCompoenents.forEach {
            XCTAssertTrue($0.alpha == 0, "Expect components hidden before view appear")
        }
        
        sut.simulateViewAppear()
        sut.fadeInCompoenents.forEach {
            XCTAssertTrue($0.alpha != 0, "Expect components shown after view appear")
        }
    }
    
    func test_voicePrompt_canShareSettingsFromDiffetentSUT() {
        let userDefaults = UserDefaultsMock()
        let sut = makeSUT(userDefaults: userDefaults)
        let anotherSut = makeSUT(userDefaults: userDefaults)

        sut.loadViewIfNeeded()
        anotherSut.loadViewIfNeeded()
        
        userDefaults.setVoicePromptOn()
        XCTAssertTrue(sut.voicePromptOn, "expect voice switch is on, matching the user preferance")
        XCTAssertTrue(anotherSut.voicePromptOn, "expect voice switch is on, matching the user preferance")

        sut.simulateToggleVoicePrompt()
        XCTAssertFalse(anotherSut.voicePromptOn, "expect voice switch is off, matching the user preferance updated by `sut`")
    }
    
    func test_voicePrompt_showsIllustrationAlertOnTurningOn() {
        let userDefaults = UserDefaultsMock()
        let sut = makeSUT(userDefaults: userDefaults)
        let window = UIWindow()
        window.addSubview(sut.view)

        userDefaults.setVoicePromptOn()
        
        sut.simulateToggleVoicePrompt()
        XCTAssertNil(sut.presentedViewController, "Expect no alert shown on turning off voice prompt")
        
        sut.simulateToggleVoicePrompt()
        let alert = try? XCTUnwrap(sut.presentedViewController as? UIAlertController, "Expect alert shown on turning on voice prompt")
        XCTAssertEqual(alert?.title, VoicePromptOnAlertPresenter.alertTitle)
        XCTAssertEqual(alert?.message, VoicePromptOnAlertPresenter.alertMessage)
        XCTAssertEqual(alert?.actions.first?.title, VoicePromptOnAlertPresenter.alertConfirmTitle)
        
        clearModalPresentationReference(sut)
    }
    
    func test_guess_showsRenderedInputView() {
        let sut = makeSUT()
        let window = UIWindow()
        window.addSubview(sut.view)
        
        sut.onGuessButtonPressed?()
        
        RunLoop.current.run(until: Date())
        
        let inputVC = (sut.presentedViewController as? UINavigationController)?.topViewController as? NumberInputViewController
        
        XCTAssertEqual(inputVC?.title, NumberInputPresenter.viewModel.viewTitle)
        XCTAssertEqual(inputVC?.clearButton.title(for: .normal), NumberInputPresenter.viewModel.clearInputAction)
        
        clearModalPresentationReference(sut)
    }
    
    func test_guess_rendersResult() {
        let answer = ["1", "2", "3", "4"]
        let secret = DigitSecret(digits: answer.compactMap(Int.init))!
        let guess1 = ["5", "2", "3", "4"]
        let guess2 = ["5", "6", "3", "4"]
        let sut = makeSUT(secret: secret)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.resultMessage, "", "expected no text after loading")
        
        sut.simulateGuess(with: guess1)
        XCTAssertEqual(sut.resultMessage, "5234          3A0B\n", "expected latest result after matching")
        
        sut.simulateGuess(with: guess2)
        XCTAssertEqual(sut.resultMessage, "5634          2A0B\n", "expected latest result after matching")
    }
    
    func test_gameOutOfChance_requestsReplenishChanceDelegateToReplenish() {
        let secret = DigitSecret(digits: [1, 2, 3, 4])!
        let wrongGuess = DigitSecret(digits: [4, 3, 2, 1])!
        let gameVersion = makeGameVersion(maxGuessCount: 2)
        let delegate = ReplenishChanceDelegateSpy()
        let sut = makeSUT(gameVersion: gameVersion, secret: secret, delegate: delegate)
        
        sut.loadViewIfNeeded()
        sut.simulateGuess(with: wrongGuess)
        XCTAssertTrue(delegate.completions.isEmpty, "Expect no request when guess chance not zero")
        
        sut.simulateGuess(with: wrongGuess)
        XCTAssertEqual(delegate.completions.count, 1, "Expect one request when out of guess chance")
        
        delegate.completeReplenish(with: 2, at: 0)
        sut.simulateGuess(with: wrongGuess)
        XCTAssertEqual(delegate.completions.count, 1, "Expect no new request when guess chance not zero")
        
        sut.simulateGuess(with: wrongGuess)
        XCTAssertEqual(delegate.completions.count, 2, "Expect another request when out of guess chance again")
        
        delegate.completeReplenish(with: 1, at: 0)
        sut.simulateGuess(with: wrongGuess)
        XCTAssertEqual(delegate.completions.count, 3, "Expect another request when out of guess chance again")
    }
    
    func test_gameLose_notifiesLoseHandler() {
        let secret = DigitSecret(digits: [1, 2, 3, 4])!
        let gameVersion = makeGameVersion(maxGuessCount: 1)
        let delegate = ReplenishChanceDelegateSpy()
        var loseCallCount = 0
        let sut = makeSUT(gameVersion: gameVersion, secret: secret, delegate: delegate, onLose: {
            loseCallCount += 1
        })
        
        sut.loadViewIfNeeded()
        sut.simulateGuess(with: DigitSecret(digits: [4, 3, 2, 1])!)
        XCTAssertEqual(loseCallCount, 0, "Expect lose handler not called before delegate complete replenishing")

        delegate.completeReplenish(with: 0)
        XCTAssertEqual(loseCallCount, 1, "Expect lose handler called once delegate complete replenishing")
    }
    
    func test_gameWin_notifiesWinHandlerAfterOutOfChanceTwice() {
        let secret = DigitSecret(digits: [1, 2, 3, 4])!
        let wrongGuess = DigitSecret(digits: [4, 3, 2, 1])!
        let gameVersion = makeGameVersion(maxGuessCount: 1)
        let delegate = ReplenishChanceDelegateSpy()
        var winCallCount = 0
        var timerCount = 0.0
        let currentDeviceTime: () -> TimeInterval = {
            timerCount += 1
            return timerCount * 3.0
        }
        var capturedScore: Score?
        let sut = makeSUT(gameVersion: gameVersion, secret: secret, delegate: delegate, currentDeviceTime: currentDeviceTime, onWin: { score in
            capturedScore = score
            winCallCount += 1
        })
        
        sut.loadViewIfNeeded()
        sut.simulateGuess(with: wrongGuess)
        XCTAssertEqual(winCallCount, 0, "Expect win handler not called before a right guess is made")

        delegate.completeReplenish(with: 1, at: 0)
        sut.simulateGuess(with: wrongGuess)
        XCTAssertEqual(winCallCount, 0, "Expect win handler not called before a right guess is made")
        
        delegate.completeReplenish(with: 1, at: 1)
        sut.simulateGuess(with: secret)
        XCTAssertEqual(winCallCount, 1, "Expect win handler called after a right guess is made")
        XCTAssertEqual(capturedScore?.guessCount, 3, "Expect score matching guess count")
        XCTAssertEqual(capturedScore?.guessTime, 3.0, "Expect score matching guess time")
    }
    
    func test_gameLose_rendersGameEnded() {
        let secret = DigitSecret(digits: [1, 2, 3, 4])!
        let gameVersion = makeGameVersion(maxGuessCount: 1)
        let delegate = ReplenishChanceDelegateSpy()
        let sut = makeSUT(gameVersion: gameVersion, secret: secret, delegate: delegate)
        
        sut.loadViewIfNeeded()
        assertGameOngoing(sut, secret: secret)
        
        sut.simulateGuess(with: DigitSecret(digits: [4, 3, 2, 1])!)
        assertGameOngoing(sut, secret: secret)

        delegate.completeReplenish(with: 0)
        assertGameEnd(sut, secret: secret)
    }
    
    func test_gameWin_rendersGameEnded() {
        let secret = DigitSecret(digits: [1, 2, 3, 4])!
        let wrongGuess = DigitSecret(digits: [4, 3, 2, 1])!
        let gameVersion = makeGameVersion(maxGuessCount: 1)
        let delegate = ReplenishChanceDelegateSpy()
        let sut = makeSUT(gameVersion: gameVersion, secret: secret, delegate: delegate)
        
        sut.loadViewIfNeeded()
        sut.simulateGuess(with: wrongGuess)
        assertGameOngoing(sut, secret: secret)

        delegate.completeReplenish(with: 1, at: 0)
        sut.simulateGuess(with: wrongGuess)
        assertGameOngoing(sut, secret: secret)

        delegate.completeReplenish(with: 1, at: 1)
        sut.simulateGuess(with: secret)
        assertGameEnd(sut, secret: secret)
    }
    
    func test_gameWin_playsMatchResultAndWinMessageIfNeeded() {
        let secret = DigitSecret(digits: [1, 2, 3, 4])!
        let synthesizer = AVSpeechSynthesizerSpy()
        let userDefaults = UserDefaultsMock()
        let sut = makeSUT(userDefaults: userDefaults, speechSynthesizer: synthesizer, secret: secret)
        
        sut.loadViewIfNeeded()
        
        sut.simulateTurnVoiewPrompt(on: false)
        sut.simulateGuess(with: secret)
        
        XCTAssertEqual(synthesizer.capturedMessages, [], "Expect no voice message when voice prompt is set to off")
        
        sut.simulateTurnVoiewPrompt(on: true)
        sut.simulateGuess(with: secret)
        
        XCTAssertEqual(synthesizer.capturedMessages, ["4A0B", GamePresenter.voiceMessageForWinning], "Expect winning voice message when voice prompt is set to on")
    }
    
    func test_gameLose_playsMatchResultAndLoseMessageIfNeeded() {
        let secret = DigitSecret(digits: [1, 2, 3, 4])!
        let gameVersion = makeGameVersion(maxGuessCount: 1)
        let synthesizer = AVSpeechSynthesizerSpy()
        let userDefaults = UserDefaultsMock()
        let delegate = ReplenishChanceDelegateSpy()
        let sut = makeSUT(gameVersion: gameVersion, userDefaults: userDefaults, speechSynthesizer: synthesizer, secret: secret, delegate: delegate)
        
        sut.loadViewIfNeeded()
        
        sut.simulateTurnVoiewPrompt(on: true)
        sut.simulateGuess(with: DigitSecret(digits: [4, 3, 2, 1])!)
        XCTAssertEqual(synthesizer.capturedMessages, ["0A4B"], "Expect playing match result")

        sut.simulateTurnVoiewPrompt(on: false)
        delegate.completeReplenish(with: 1, at: 0)
        sut.simulateGuess(with: DigitSecret(digits: [4, 3, 2, 0])!)
        XCTAssertEqual(synthesizer.capturedMessages, ["0A4B"], "Expect no voice message when voice prompt is set to off")

        sut.simulateTurnVoiewPrompt(on: true)
        delegate.completeReplenish(with: 0, at: 1)
        XCTAssertEqual(synthesizer.capturedMessages, ["0A4B", GamePresenter.voiceMessageForLosing], "Expect playing lose message on game lose")
    }
    
    func test_guessAndReplenish_rendersAvailableGuessCount() {
        let gameVersion = makeGameVersion(maxGuessCount: 3)
        let secret = DigitSecret(digits: [1, 2, 3, 4])!
        let wrongGuess = DigitSecret(digits: [4, 3, 2, 1])!
        let delegate = ReplenishChanceDelegateSpy()
        let sut = makeSUT(gameVersion: gameVersion, secret: secret, delegate: delegate)

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: 3), "Expect max guess count once view is loaded")

        sut.simulateGuess(with: wrongGuess)
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: 2), "Expect guess count minus 1 after user guess")

        sut.simulateGuess(with: wrongGuess)
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: 1), "Expect guess count minus 1 after user guess")

        sut.simulateGuess(with: wrongGuess)
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: 0), "Expect guess count minus 1 after user guess")
        
        delegate.completeReplenish(with: 5)
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: 5), "Expect guess count increases replenish chance count")
    }
    
    func test_restart_notifiesRestartHandler() {
        var restartCallCount = 0
        let sut = makeSUT(onRestart: {
            restartCallCount += 1
        })
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(restartCallCount, 0, "Expect no restart called on view load")

        sut.simulateUserRestartGame()
        XCTAssertEqual(restartCallCount, 1, "Expect restart called after user restarts the game")
    }
    
    func test_giveUp_showAlertWithProperDescriptionOnTapGiveUpButton() {
        let sut = makeSUT()
        let window = UIWindow()
        window.addSubview(sut.view)

        sut.simulateTapGiveUpButton()
        
        let alert = try? XCTUnwrap(sut.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert?.title, GamePresenter.giveUpConfirmMessage)
        XCTAssertEqual(alert?.actions.first?.title, GamePresenter.confirmGiveUpAction)
        XCTAssertEqual(alert?.actions.last?.title, GamePresenter.cancelGiveUpAction)
        
        clearModalPresentationReference(sut)
    }
    
    func test_giveUp_notifiesLoseHandlerOnConfirmingGiveUp() {
        var loseCallCount = 0
        let sut = makeSUT(onLose: {
            loseCallCount += 1
        })
        let window = UIWindow()
        window.addSubview(sut.view)

        XCTAssertEqual(loseCallCount, 0, "Expect lose handler not called on view load")

        sut.simulateTapGiveUpButton()
        let alert1 = try? XCTUnwrap(sut.presentedViewController as? UIAlertController)
        alert1?.tapCancelButton()
        XCTAssertEqual(loseCallCount, 0, "Expect lose handler not called on cancel alert")
        
        sut.simulateTapGiveUpButton()
        let alert2 = try? XCTUnwrap(sut.presentedViewController as? UIAlertController)
        alert2?.tapConfirmButton()
        XCTAssertEqual(loseCallCount, 1, "Expect give up called on confirming")
        
        clearModalPresentationReference(sut)
    }
    
    func test_giveUp_rendersGameEndedOnConfirmingGiveUp() {
        let secret = DigitSecret(digits: [1, 2, 3, 4])!
        let sut = makeSUT(secret: secret)
        let window = UIWindow()
        window.addSubview(sut.view)

        sut.simulateTapGiveUpButton()
        let alert2 = try? XCTUnwrap(sut.presentedViewController as? UIAlertController)
        alert2?.tapConfirmButton()

        assertGameEnd(sut, secret: secret)
        
        clearModalPresentationReference(sut)
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
    
    func test_helperView_showsIllustrationAlertOnTappingInfoButton() {
        let sut = makeSUT(animate: { _, _, completion in
            completion?(true)
        })
        let window = UIWindow()
        window.addSubview(sut.view)
        
        sut.simulateTapHelperButton()
        
        XCTAssertNil(sut.presentedViewController, "Expect no alert shown before tapping info button")
        
        sut.simulateTapHelperViewInfoButton()
        
        let alert = try? XCTUnwrap(sut.presentedViewController as? UIAlertController, "Expect alert shown after tapping info button")
        XCTAssertEqual(alert?.title, HelperPresenter.infoAlertTitle)
        XCTAssertEqual(alert?.message, HelperPresenter.infoAlertMessage)
        XCTAssertEqual(alert?.actions.first?.title, HelperPresenter.infoAlertConfirmTitle)
        
        clearModalPresentationReference(sut)
    }
    
    func test_instruction_showsByTappingInstructionButton() {
        let sut = makeSUT()
        let nav = UINavigationController(rootViewController: sut)
        
        sut.loadViewIfNeeded()
        XCTAssertNil(nav.topViewController as? InstructionViewController)
        
        sut.simulateTapInstructionButton()
        RunLoop.current.run(until: Date())
        let instructionVC = try? XCTUnwrap(nav.topViewController as? InstructionViewController)
        instructionVC?.loadViewIfNeeded()
        XCTAssertEqual(instructionVC?.instructionTextView.text, GameInstructionPresenter.instruction)
    }

    // MARK: Helpers
    
    private func makeSUT(title: String = "",
                         gameVersion: GameVersion = .basic,
                         userDefaults: UserDefaults = UserDefaultsMock(),
                         speechSynthesizer: AVSpeechSynthesizer = AVSpeechSynthesizerSpy(),
                         secret: DigitSecret = DigitSecret(digits: [])!,
                         delegate: ReplenishChanceDelegate = ReplenishChanceDelegateSpy(),
                         currentDeviceTime: @escaping () -> TimeInterval = CACurrentMediaTime,
                         onWin: @escaping (Score) -> Void = { _ in },
                         onLose: @escaping () -> Void = {},
                         onRestart: @escaping () -> Void = {},
                         animate: @escaping Animate = { _, _, completion in completion?(true) },
                         file: StaticString = #filePath,
                         line: UInt = #line) -> GuessNumberViewController {
        let sut = GameUIComposer.gameComposedWith(title: title, gameVersion: gameVersion, userDefaults: userDefaults, speechSynthesizer: speechSynthesizer, secret: secret, delegate: delegate, currentDeviceTime: currentDeviceTime, onWin: onWin, onLose: onLose, onRestart: onRestart, animate: animate)
        
        trackForMemoryLeaks(userDefaults, file: file, line: line)
        trackForMemoryLeaks(speechSynthesizer, file: file, line: line)
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
         String.localizedStringWithFormat(GamePresenter.guessChanceCountFormat, guessCount)
    }
    
    private func assertGameOngoing(_ sut: GuessNumberViewController, secret: DigitSecret) {
        XCTAssertTrue(sut.isShowingGameOngoingComponents)
        XCTAssertFalse(sut.isShowingGameEndedComponents)
        XCTAssertFalse(sut.isShowingSecret(secret: secret))
    }
    
    private func assertGameEnd(_ sut: GuessNumberViewController, secret: DigitSecret) {
        XCTAssertFalse(sut.isShowingGameOngoingComponents)
        XCTAssertTrue(sut.isShowingGameEndedComponents)
        XCTAssertTrue(sut.isShowingSecret(secret: secret))
    }
    
    private func localizedInApp(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Localizable"
        let bundle = Bundle.main
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        
        return value
    }
    
    private final class ReplenishChanceDelegateSpy: ReplenishChanceDelegate {
        private(set) var completions = [((Int) -> Void)]()
        
        func replenishChance(completion: @escaping (Int) -> Void) {
            completions.append(completion)
        }
        
        func completeReplenish(with chanceCount: Int, at index: Int = 0) {
            completions[index](chanceCount)
        }
    }
    
    private final class AVSpeechSynthesizerSpy: AVSpeechSynthesizer {
        var capturedMessages = [String]()
        
        override func speak(_ utterance: AVSpeechUtterance) {
            capturedMessages.append(utterance.speechString)
        }
    }
}

private extension GuessNumberViewController {
    var inputDelegate: NumberInputViewControllerDelegate? { delegate as? GamePresentationAdapter }
    
    var fadeInCompoenents: [UIView] { fadeOutViews }
    
    var availableGuessMessage: String? { availableGuessLabel.text }
    
    var resultMessage: String? { hintViewController.hintLabel.text }
    
    var voicePromptOn: Bool { (navigationItem.leftBarButtonItem!.customView as! UISwitch).isOn }
    
    var showingHelperView: Bool {
        if let helperView = helperViewController?.helperBoardView {
            return !helperView.isHidden
        } else {
            return false
        }
    }
    
    var isShowingGameEndedComponents: Bool {
        guessButton.isHidden && giveUpButton.isHidden && !restartButton.isHidden && helperViewController.helperBoardView.isHidden
    }
    
    var isShowingGameOngoingComponents: Bool {
        !guessButton.isHidden && !giveUpButton.isHidden && restartButton.isHidden
    }
    
    func isShowingSecret(secret: DigitSecret) -> Bool {
        for (index, label) in quizLabelViewController.quizLabels.enumerated() {
            if label.text != secret.content[index].description {
                return false
            }
        }
        
        return true
    }
    
    func guessHistoryViewTitle() -> String? {
        guessHistoryTitleLabel.text
    }
    
    func guessButtonTitle() -> String? {
        guessButton.title(for: .normal)
    }
    
    func giveUpButtonTitle() -> String? {
        giveUpButton.title(for: .normal)
    }
    
    func restartButtonTitle() -> String? {
        restartButton.title(for: .normal)
    }
    
    func simulateViewAppear() { viewWillAppear(false) }
    
    func simulateUserInitiateGuess() {
        inputDelegate?.didFinishEntering(numberTexts: ["1", "2", "3", "4"])
    }
    
    func simulateGuess(with guess: [String]) {
        inputDelegate?.didFinishEntering(numberTexts: guess)
    }
    
    func simulateGuess(with guess: DigitSecret) {
        inputDelegate?.didFinishEntering(numberTexts: guess.content.compactMap(String.init))
    }
    
    func simulateTapHelperButton() {
        helperViewController?.helperBtnPressed(self)
    }
    
    func simulateTapHelperViewInfoButton() {
        helperViewController.helperInfoBtnPressed(self)
    }
    
    func simulateToggleVoicePrompt() {
        guard let voiceView = navigationItem.leftBarButtonItem?.customView as? UISwitch else { return }
        voiceView.isOn = !voiceView.isOn
        voiceView.sendActions(for: .valueChanged)
    }
    
    func simulateUserRestartGame() {
        restartButton.sendActions(for: .touchUpInside)
    }
    
    func simulateTapGiveUpButton() {
        giveUpButton.sendActions(for: .touchUpInside)
    }
    
    func simulateTapInstructionButton() {
        navigationItem.rightBarButtonItems?.first?.simulateTap()
    }
    
    func simulateTurnVoiewPrompt(on: Bool) {
        (navigationItem.leftBarButtonItem?.customView as? UISwitch)?.setOn(on, animated: false)
    }
}

private extension UserDefaults {
    func setVoicePromptOn() { set(true, forKey: "VOICE_PROMPT") }
    func setVoicePromptOff() { set(false, forKey: "VOICE_PROMPT") }
}

private extension UIBarButtonItem {
    func simulateTap() {
        target!.performSelector(onMainThread: action!, with: nil, waitUntilDone: true)
    }
}

private extension UIAlertController {
    typealias AlertHandler = @convention(block) (UIAlertAction) -> Void

    private func tapButton(atIndex index: Int) {
        guard let block = actions[index].value(forKey: "handler") else { return }
        let handler = unsafeBitCast(block as AnyObject, to: AlertHandler.self)
        handler(actions[index])
    }
    
    func tapConfirmButton() {
        tapButton(atIndex: 0)
    }
    
    func tapCancelButton() {
        tapButton(atIndex: 1)
    }
}
