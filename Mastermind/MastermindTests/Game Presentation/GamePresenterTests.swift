//
//  GamePresenterTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/9/23.
//

import XCTest

public struct LeftChanceCountViewModel {
    public let message: String
    public let shouldBeAwareOfChanceCount: Bool
}

private protocol GameView {
    func display(_ viewModel: LeftChanceCountViewModel)
}

private final class GamePresenter {
    private let gameView: GameView
    
    init(gameView: GameView) {
        self.gameView = gameView
    }
    
    public static var guessChanceCountFormat: String {
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
            case display(leftCountMessage: String, shouldBeAwareOfLeftCount: Bool)
        }
        
        private(set) var receivedMessages = [Message]()
        
        func display(_ viewModel: LeftChanceCountViewModel) {
            receivedMessages.append(.display(leftCountMessage: viewModel.message, shouldBeAwareOfLeftCount: viewModel.shouldBeAwareOfChanceCount))
        }
    }
}
