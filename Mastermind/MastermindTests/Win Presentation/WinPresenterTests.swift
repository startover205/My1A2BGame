//
//  WinPresenterTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/9/30.
//

import XCTest
import Mastermind

class WinPresenterTests: XCTestCase {
    func test_shareMessageFormat_isLocalized() {
        XCTAssertEqual(WinPresenter.shareMessageFormat, localized("%d_SHARE_MESSAGE_FORMAT"))
    }
    
    func test_init_doesNotMessageView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.receivedMessages.isEmpty)
    }
    
    func test_didRequestWinResultMessage_displaysWinMessageAndGuessCountMessage() {
        let digitCount = 3
        let guessCount = 11
        let (sut, view) = makeSUT(digitCount: digitCount, guessCount: guessCount)
        
        sut.didRequestWinResultMessage()
        
        XCTAssertEqual(view.receivedMessages, [.display(
                                                winMessage: String.localizedStringWithFormat(localized("%d_WIN_MESSAGE_FORMAT"), digitCount),
                                                guessCountMessage: String.localizedStringWithFormat(localized("%d_GUESS_COUNT_MESSAGE_FORMAT"), guessCount))])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(digitCount: Int = 0, guessCount: Int = 0, file: StaticString = #filePath, line: UInt = #line) -> (WinPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = WinPresenter(digitCount: digitCount, guessCount: guessCount, winView: view)
        
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, view)
    }
    
    private final class ViewSpy: WinView {
        enum Message: Hashable {
            case display(winMessage: String, guessCountMessage: String)
        }
        
        private(set) var receivedMessages = Set<Message>()
        
        func display(_ viewModel: WinResultViewModel) {
            receivedMessages.insert(.display(winMessage: viewModel.winMessage, guessCountMessage: viewModel.guessCountMessage))
        }
    }
    
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Win"
        let bundle = Bundle(for: WinPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
