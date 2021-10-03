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
    
    func test_resultViewModel_providesWinMessageAndGuessCountMessage() {
        let digitCount = 3
        let guessCount = 11
        let sut = makeSUT(digitCount: digitCount, guessCount: guessCount)
        
        XCTAssertEqual(sut.resultViewModel.winMessage, String.localizedStringWithFormat(localized("%d_WIN_MESSAGE_FORMAT"), digitCount))
        XCTAssertEqual(sut.resultViewModel.guessCountMessage, String.localizedStringWithFormat(localized("%d_GUESS_COUNT_MESSAGE_FORMAT"), guessCount))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(digitCount: Int = 0, guessCount: Int = 0, file: StaticString = #filePath, line: UInt = #line) -> WinPresenter {
        let sut = WinPresenter(digitCount: digitCount, guessCount: guessCount)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
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
