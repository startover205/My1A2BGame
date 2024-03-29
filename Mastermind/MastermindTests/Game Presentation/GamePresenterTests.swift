//
//  GamePresenterTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/9/23.
//

import XCTest
import Mastermind

class GamePresenterTests: XCTestCase {
    
    func test_sceneViewModel_isLocalized() {
        XCTAssertEqual(GamePresenter.sceneViewModel.guessHistoryViewTitle, localized("GUESS_HISTORY_VIEW_TITLE"))
        XCTAssertEqual(GamePresenter.sceneViewModel.guessAction, localized("GUESS_ACTION"))
        XCTAssertEqual(GamePresenter.sceneViewModel.giveUpAction, localized("GIVE_UP_ACTION"))
        XCTAssertEqual(GamePresenter.sceneViewModel.restartAction, localized("RESTART_ACTION"))
    }

    func test_init_doesNotMessageView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.receivedMessages.isEmpty)
    }
    
    func test_didUpdateLeftChanceCount_displaysLeftChanceCountMessageWithoutWarningWhenLeftChancesStillSufficient() {
        let (sut, view) = makeSUT()
        
        sut.didUpdateLeftChanceCount(4)
        XCTAssertEqual(view.receivedMessages, [
                        .display(leftCountMessage: String.localizedStringWithFormat(localized("%d_GUESS_CHANCE_COUNT_FORMAT"), 4), shouldBeAwareOfLeftCount: false)])
        
    }
    
    func test_didUpdateLeftChanceCount_displaysLeftChanceCountMessageWithWarningWhenLeftChancesTooLittle() {
        let (sut, view) = makeSUT()
        
        sut.didUpdateLeftChanceCount(3)
        XCTAssertEqual(view.receivedMessages, [
                        .display(leftCountMessage: String.localizedStringWithFormat(localized("%d_GUESS_CHANCE_COUNT_FORMAT"), 3), shouldBeAwareOfLeftCount: true)])
    }
    
    func test_didMatchGuess_displaysMatchResultAndVoiceMessage() {
        let guesss = DigitSecret(digits: [1, 2, 3, 4])!
        let matchResult = MatchResult(bulls: 3, cows: 1, correct: true)
        let (sut, view) = makeSUT()
        
        sut.didMatchGuess(guess: guesss, result: matchResult)
        
        XCTAssertEqual(view.receivedMessages, [
                        .display(matchCorrect: matchResult.correct, resultMesssage: "1234          3A1B\n"),
                        .display(voiceMessage: "3A1B")])
    }
    
    func test_didWinGame_displaysGameEndAndPlaysWinMessage() {
        let (sut, view) = makeSUT()
        
        sut.didWinGame()
        
        XCTAssertEqual(view.receivedMessages, [
                        .display(voiceMessage: localized("WIN_VOICE_MESSAGE")),
                        .displayGameEnd])
    }
    
    func test_didLoseGame_displaysGameEndAndPlaysLoseMessage() {
        let (sut, view) = makeSUT()
        
        sut.didLoseGame()
        
        XCTAssertEqual(view.receivedMessages, [
                        .display(voiceMessage: localized("LOSE_VOICE_MESSAGE")),
                        .displayGameEnd])
    }
    
    func test_didTapGiveUpButton_displayGiveUpConfirmMessage() {
        let (sut, view) = makeSUT()
        
        sut.didTapGiveUpButton()
        
        XCTAssertEqual(view.receivedMessages,
                       [ .displayGiveUpConfirmMessage(
                            message: localized("GIVE_UP_CONFIRM_MESSAGE"),
                            confirmAction: localized("CONFIRM_GIVE_UP_ACTION"),
                            cancelAction: localized("CANCEL_GIVE_UP_ACTION"))],
                       "Expect displaying localized alert content")
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (GamePresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = GamePresenter(gameView: view, utteranceView: view)
        
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, view)
    }
    
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Game"
        let bundle = Bundle(for: GamePresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
    
    private final class ViewSpy: GameView, UtteranceView {
        enum Message: Hashable {
            case display(leftCountMessage: String,
                         shouldBeAwareOfLeftCount: Bool)
            case display(matchCorrect: Bool,
                         resultMesssage: String)
            case display(voiceMessage: String)
            case displayGiveUpConfirmMessage(message: String, confirmAction: String, cancelAction: String)
            case displayGameEnd
        }
        
        private(set) var receivedMessages = Set<Message>()
        
        func display(_ viewModel: LeftChanceCountViewModel) {
            receivedMessages.insert(.display(leftCountMessage: viewModel.message, shouldBeAwareOfLeftCount: viewModel.shouldBeAwareOfChanceCount))
        }
        
        func display(_ viewModel: MatchResultViewModel) {
            receivedMessages.insert(.display(matchCorrect: viewModel.matchCorrect, resultMesssage: viewModel.resultMessage))
        }
        
        func display(_ viewModel: VoiceMessageViewModel) {
            receivedMessages.insert(.display(voiceMessage: viewModel.message))
        }
        
        func display(_ viewModel: GiveUpConfirmViewModel) {
            receivedMessages.insert(.displayGiveUpConfirmMessage(message: viewModel.message, confirmAction: viewModel.confirmAction, cancelAction: viewModel.cancelAction))
        }
        
        func displayGameEnd() {
            receivedMessages.insert(.displayGameEnd)
        }
    }
}
