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
