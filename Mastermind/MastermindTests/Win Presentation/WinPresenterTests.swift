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
    
    func test_didRequestWinMessage_displaysWinMessage() {
        let digitCount = 4
        let (sut, view) = makeSUT(digitCount: digitCount)
        
        sut.didRequestWinMessage()
        
        XCTAssertEqual(view.receivedMessages, [.display(winMessage: String.localizedStringWithFormat(localized("%d_WIN_MESSAGE_FORMAT"), digitCount))])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(digitCount: Int = 0, file: StaticString = #filePath, line: UInt = #line) -> (WinPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = WinPresenter(digitCount: digitCount, winView: view)
        
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, view)
    }
    
    private final class ViewSpy: WinView {
        enum Message: Hashable {
            case display(winMessage: String)
        }
        
        private(set) var receivedMessages = Set<Message>()
        
        func display(_ viewModel: WinMessageViewModel) {
            receivedMessages.insert(.display(winMessage: viewModel.message))
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
