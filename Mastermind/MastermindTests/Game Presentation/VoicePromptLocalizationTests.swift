//
//  VoicePromptLocalizationTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/9/27.
//

import XCTest
import Mastermind

class VoicePromptLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "VoicePrompt"
        let bundle = Bundle(for: VoicePromptOnAlertPresenter.self)
        
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
