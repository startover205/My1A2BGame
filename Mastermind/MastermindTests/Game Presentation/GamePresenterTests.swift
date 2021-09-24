//
//  GamePresenterTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/9/23.
//

import XCTest
import Mastermind

protocol GameView {
    func display(_ viewModel: LeftChanceCountViewModel)
    func display(_ viewModel: MatchResultViewModel)
}

struct MatchResultViewModel {
    let matchCorrect: Bool
    let resultMessage: String
    let voiceMessage: String
}

struct LeftChanceCountViewModel {
    let message: String
    let shouldBeAwareOfChanceCount: Bool
}

final class GamePresenter {
    private let gameView: GameView
    
    init(gameView: GameView) {
        self.gameView = gameView
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
        
        let voiceMessage = hint
        
        gameView.display(MatchResultViewModel(
                            matchCorrect: result.correct,
                            resultMessage: resultMessage,
                            voiceMessage: voiceMessage))
    }
}

class GamePresenterTests: XCTestCase {

    func test_init_doesNotMessageView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.receivedMessages.isEmpty)
    }
    
    func test_didUpdateLeftChanceCount_displaysLeftChanceCountMessage() {
        let (sut, view) = makeSUT()
        
        sut.didUpdateLeftChanceCount(4)
        XCTAssertEqual(view.receivedMessages, [.display(leftCountMessage: String.localizedStringWithFormat(localized("%d_GUESS_CHANCE_COUNT_FORMAT"), 4), shouldBeAwareOfLeftCount: false)], "Expect displaying left chance count message but don't have to remind user to be aware of the left chance count")
        
        sut.didUpdateLeftChanceCount(3)
        XCTAssertEqual(view.receivedMessages, [
                        .display(leftCountMessage: String.localizedStringWithFormat(localized("%d_GUESS_CHANCE_COUNT_FORMAT"), 4), shouldBeAwareOfLeftCount: false),
                        .display(leftCountMessage: String.localizedStringWithFormat(localized("%d_GUESS_CHANCE_COUNT_FORMAT"), 3), shouldBeAwareOfLeftCount: true)], "Expect displaying left chance count message and remind user to be aware of the left chance count")
    }
    
    func test_didMatchGuess_displaysMatchResultAndVoiceMessage() {
        let guesss = DigitSecret(digits: [1, 2, 3, 4])!
        let matchResult = MatchResult(bulls: 3, cows: 1, correct: true)
        let (sut, view) = makeSUT()
        
        sut.didMatchGuess(guess: guesss, result: matchResult)
        
        XCTAssertEqual(view.receivedMessages, [.display(matchCorrect: matchResult.correct, resultMesssage: "1234          3A1B\n", voiceMessage: "3A1B")])
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (GamePresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = GamePresenter(gameView: view)
        
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
    
    private final class ViewSpy: GameView {
        enum Message: Equatable {
            case display(leftCountMessage: String,
                         shouldBeAwareOfLeftCount: Bool)
            case display(matchCorrect: Bool,
                         resultMesssage: String,
                         voiceMessage: String)
        }
        
        private(set) var receivedMessages = [Message]()
        
        func display(_ viewModel: LeftChanceCountViewModel) {
            receivedMessages.append(.display(leftCountMessage: viewModel.message, shouldBeAwareOfLeftCount: viewModel.shouldBeAwareOfChanceCount))
        }
        
        func display(_ viewModel: MatchResultViewModel) {
            receivedMessages.append(.display(matchCorrect: viewModel.matchCorrect, resultMesssage: viewModel.resultMessage, voiceMessage: viewModel.voiceMessage))
        }
    }
}
