//
//  RewardAdPresenterTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/9/28.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame

class RewardAdPresenterTests: XCTestCase {
    func test_alertTitle_isLocalized() {
        XCTAssertEqual(RewardAdPresenter.alertTitle, localized("ALERT_TITLE"))
    }
    
    func test_alertMessage_isLocalized() {
        XCTAssertEqual(RewardAdPresenter.alertMessageFormat, localized("%d_ALERT_MESSAGE_FORMAT"))
    }
    
    func test_alertCancelTitle_isLocalized() {
        XCTAssertEqual(RewardAdPresenter.alertCancelTitle, localized("ALERT_CANCEL_TITLE"))
    }
    
    func test_alertCountDownTime() {
        XCTAssertEqual(RewardAdPresenter.alertCountDownTime, 5.0)
    }
    
    // MARK: - Helpers
    
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "RewardAd"
        let bundle = Bundle(for: RewardAdPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
