//
//  GamePresenterTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/9/23.
//

import XCTest
import Mastermind

protocol UtteranceView {
    func display(_ viewModel: VoiceMessageViewModel)
}

struct VoiceMessageViewModel {
   public let message: String
}

protocol GameView {
    func display(_ viewModel: LeftChanceCountViewModel)
    func display(_ viewModel: MatchResultViewModel)
}

struct MatchResultViewModel {
    let matchCorrect: Bool
    let resultMessage: String
}
    
struct LeftChanceCountViewModel {
    let message: String
    let shouldBeAwareOfChanceCount: Bool
}

final class GamePresenter {
    private let gameView: GameView
    private let utteranceView: UtteranceView
    
    init(gameView: GameView, utteranceView: UtteranceView) {
        self.gameView = gameView
        self.utteranceView = utteranceView
    }
    
    private static var guessChanceCountFormat: String {
        NSLocalizedString("%d_GUESS_CHANCE_COUNT_FORMAT",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Format for the left chance count")
    }
    
    func didUpdateLeftChanceCount(_ leftChanceCount: Int) {
        let message = String.localizedStringWithFormat(Self.guessChanceCountFormat, leftChanceCount)
        let shouldBeAwareOfChanceCount = leftChanceCount <= 3
        gameView.display(LeftChanceCountViewModel(message: message, shouldBeAwareOfChanceCount: shouldBeAwareOfChanceCount))
    }
    
    public func didMatchGuess(guess: DigitSecret, result: MatchResult) {
        let hint = "\(result.bulls)A\(result.cows)B"
        let resultMessage = guess.content.compactMap(String.init).joined() + "          " + "\(hint)\n"
        
        gameView.display(MatchResultViewModel(
                            matchCorrect: result.correct,
                            resultMessage: resultMessage))
        
        utteranceView.display(VoiceMessageViewModel(message: hint))
    }
}

class GamePresenterTests: XCTestCase {

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
    }
}
