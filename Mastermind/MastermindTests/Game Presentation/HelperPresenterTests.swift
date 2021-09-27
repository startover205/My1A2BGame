//
//  HelperPresenterTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/9/27.
//

import XCTest

final class HelperPresenter {
    private init() {}
    
    public static var infoAlertTitle: String {
        NSLocalizedString("HELPER_INFO_ALERT_TITLE",
                          tableName: "Helper",
                          bundle: Bundle(for: HelperPresenter.self),
                          comment: "Title for helper info alert")
    }
    
    public static var infoAlertMessage: String {
        NSLocalizedString("HELPER_INFO_ALERT_MESSAGE",
                          tableName: "Helper",
                          bundle: Bundle(for: HelperPresenter.self),
                          comment: "Message for helper info alert")
    }
    
    public static var infoAlertConfirmTitle: String {
        NSLocalizedString("HELPER_INFO_ALERT_CONFIRM_TITLE",
                          tableName: "Helper",
                          bundle: Bundle(for: HelperPresenter.self),
                          comment: "Confirm Title for helper info alert")
    }
}

class HelperPresenterTests: XCTestCase {

    func test_infoAlertTitle_isLocalized() {
        XCTAssertEqual(HelperPresenter.infoAlertTitle, localized("HELPER_INFO_ALERT_TITLE"))
    }

    func test_infoAlertMessage_isLocalized() {
        XCTAssertEqual(HelperPresenter.infoAlertMessage, localized("HELPER_INFO_ALERT_MESSAGE"))
    }
    
    func test_infoAlertConfirmTitle_isLocalized() {
        XCTAssertEqual(HelperPresenter.infoAlertConfirmTitle, localized("HELPER_INFO_ALERT_CONFIRM_TITLE"))
    }
    
    // MARK: Helpers
    
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Helper"
        let bundle = Bundle(for: HelperPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
