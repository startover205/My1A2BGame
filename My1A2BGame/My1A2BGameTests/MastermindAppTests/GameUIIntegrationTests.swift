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
        let sut = makeSUT(title: "a title")
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, "a title")
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
        let sut = makeSUT(gameVersion: gameVersion, secret: secret, delegate: delegate, onWin: {
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
    }
    
    func test_gameLose_rendersGameEnded() {
        let secret = DigitSecret(digits: [1, 2, 3, 4])!
        let gameVersion = makeGameVersion(maxGuessCount: 1)
        let delegate = ReplenishChanceDelegateSpy()
        let sut = makeSUT(gameVersion: gameVersion, secret: secret, delegate: delegate)
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingGameOngoingComponents, "Expect game ongoing before game lose")
        XCTAssertFalse(sut.isShowingGameEndedComponents, "Expect game not ended before game lose")
        XCTAssertFalse(sut.isShowingSecret(secret: secret), "Expect hiding secret before game lose")
        
        sut.simulateGuess(with: DigitSecret(digits: [4, 3, 2, 1])!)
        XCTAssertTrue(sut.isShowingGameOngoingComponents, "Expect game ongoing before game lose")
        XCTAssertFalse(sut.isShowingGameEndedComponents, "Expect game not ended before game lose")
        XCTAssertFalse(sut.isShowingSecret(secret: secret), "Expect hiding secret before game lose")

        delegate.completeReplenish(with: 0)
        XCTAssertFalse(sut.isShowingGameOngoingComponents, "Expect game not ongoing after game lose")
        XCTAssertTrue(sut.isShowingGameEndedComponents, "Expect game ended after game lose")
        XCTAssertTrue(sut.isShowingSecret(secret: secret), "Expect showing secret after game lose")
    }
    
    
    func test_gameWin_rendersGameEnded() {
        let secret = DigitSecret(digits: [1, 2, 3, 4])!
        let wrongGuess = DigitSecret(digits: [4, 3, 2, 1])!
        let gameVersion = makeGameVersion(maxGuessCount: 1)
        let delegate = ReplenishChanceDelegateSpy()
        var winCallCount = 0
        let sut = makeSUT(gameVersion: gameVersion, secret: secret, delegate: delegate, onWin: {
            winCallCount += 1
        })
        
        sut.loadViewIfNeeded()
        sut.simulateGuess(with: wrongGuess)
        XCTAssertTrue(sut.isShowingGameOngoingComponents, "Expect game ongoing before game win")
        XCTAssertFalse(sut.isShowingGameEndedComponents, "Expect game not ended before game win")
        XCTAssertFalse(sut.isShowingSecret(secret: secret), "Expect hiding secret before game win")

        delegate.completeReplenish(with: 1, at: 0)
        sut.simulateGuess(with: wrongGuess)
        XCTAssertTrue(sut.isShowingGameOngoingComponents, "Expect game ongoing before game win")
        XCTAssertFalse(sut.isShowingGameEndedComponents, "Expect game not ended before game win")
        XCTAssertFalse(sut.isShowingSecret(secret: secret), "Expect hiding secret before game win")

        delegate.completeReplenish(with: 1, at: 1)
        sut.simulateGuess(with: secret)
        XCTAssertFalse(sut.isShowingGameOngoingComponents, "Expect game not ongoing after game win")
        XCTAssertTrue(sut.isShowingGameEndedComponents, "Expect game ended after game win")
        XCTAssertTrue(sut.isShowingSecret(secret: secret), "Expect showing secret after game win")
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
        XCTAssertEqual(restartCallCount, 0, "Expect no restart called on view load")

        sut.simulateUserRestartGame()
        XCTAssertEqual(restartCallCount, 1, "Expect restart called after user restarts the game")
    }
    
    func test_giveUp_notifiesGiveUpHandler() {
        var giveUpCallCount = 0
        let sut = makeSUT()
        sut.onGiveUp = {
            giveUpCallCount += 1
        }

        sut.loadViewIfNeeded()
        XCTAssertEqual(giveUpCallCount, 0, "Expect no give up called on view load")

        sut.simulateUserGiveUpGame()
        XCTAssertEqual(giveUpCallCount, 1, "Expect give up called after user gives up the game")
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
    
    func test_instruction_showsByTappingInstructionButton() {
        let sut = makeSUT()
        let nav = UINavigationController(rootViewController: sut)
        
        sut.loadViewIfNeeded()
        XCTAssertFalse(nav.topViewController is InstructionViewController)
        
        sut.simulateTapInstructionButton()
        RunLoop.current.run(until: Date())
        XCTAssertTrue(nav.topViewController is InstructionViewController)
    }

    // MARK: Helpers
    
    private func makeSUT(title: String = "", gameVersion: GameVersion = .basic, userDefaults: UserDefaults = UserDefaultsMock(), secret: DigitSecret = DigitSecret(digits: [])!, guessCompletion: @escaping GuessCompletion = { _ in (nil, false)}, delegate: ReplenishChanceDelegate = ReplenishChanceDelegateSpy(), onWin: @escaping () -> Void = {}, onLose: @escaping () -> Void = {}, onRestart: @escaping () -> Void = {}, animate: @escaping Animate = { _, _, completion in completion?(true) }, file: StaticString = #filePath, line: UInt = #line) -> GuessNumberViewController {
        let sut = GameUIComposer.gameComposedWith(title: title, gameVersion: gameVersion, userDefaults: userDefaults, loader: RewardAdLoaderFake(), secret: secret, delegate: delegate, onWin: onWin, onLose: onLose, onRestart: onRestart, animate: animate)
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
    
    private final class RewardAdLoaderFake: RewardAdLoader {
        var rewardAd: RewardAd?
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
    
    var isShowingGameEndedComponents: Bool {
        guessButton.isHidden && quitButton.isHidden && !restartButton.isHidden && helperViewController.helperBoardView.isHidden
    }
    
    var isShowingGameOngoingComponents: Bool {
        !guessButton.isHidden && !quitButton.isHidden && restartButton.isHidden
    }
    
    func isShowingSecret(secret: DigitSecret) -> Bool {
        for (index, label) in quizLabelViewController.quizLabels.enumerated() {
            if label.text != secret.content[index].description {
                return false
            }
        }
        
        return true
    }
    
    func simulateViewAppear() { viewWillAppear(false) }
    
    func simulateUserInitiateGuess() {
        inputVC.delegate?.padDidFinishEntering(numberTexts: ["1", "2", "3", "4"])
    }
    
    func simulateGuess(with guess: [String]) {
        tryToMatchNumbers(guessTexts: guess)
    }
    
    func simulateGuess(with guess: DigitSecret) {
        tryToMatchNumbers(guessTexts: guess.content.compactMap(String.init))
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
        onGameLose()
        RunLoop.current.run(until: Date())
    }
    
    func simulateUserRestartGame() {
        restartButton.sendActions(for: .touchUpInside)
    }
    
    func simulateUserGiveUpGame() {
        quitButton.sendActions(for: .touchUpInside)
    }
    
    func simulateTapInstructionButton() {
        navigationItem.rightBarButtonItems?.first?.simulateTap()
    }
}

private extension UserDefaults {
    func setVoicePromptOn() { setValue(true, forKey: "VOICE_PROMPT") }
}

private extension UIBarButtonItem {
    func simulateTap() {
        target!.performSelector(onMainThread: action!, with: nil, waitUntilDone: true)
    }
}
