//
//  VoicePromptOnAlertPresenterTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/9/27.
//

import XCTest
import Mastermind

class VoicePromptOnAlertPresenterTests: XCTestCase {
    
    func test_alertTitle_isLocalized() {
        XCTAssertEqual(VoicePromptOnAlertPresenter.alertTitle, localized("VOICE_PROMPT_ON_ALERT_TITLE"))
    }

    func test_alertMessage_isLocalized() {
        XCTAssertEqual(VoicePromptOnAlertPresenter.alertMessage, localized("VOICE_PROMPT_ON_ALERT_MESSAGE"))
    }

    func test_alertConfirmTitle_isLocalized() {
        XCTAssertEqual(VoicePromptOnAlertPresenter.alertConfirmTitle, localized("VOICE_PROMPT_ON_ALERT_CONFIRM_TITLE"))
    }
    
    // MARK: Helpers
    
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "VoicePrompt"
        let bundle = Bundle(for: VoicePromptOnAlertPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
