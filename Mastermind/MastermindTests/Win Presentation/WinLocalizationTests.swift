//
//  WinLocalizationTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/10/1.
//

import XCTest
import Mastermind

class WinLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Win"
        let bundle = Bundle(for: WinPresenter.self)
        
        assertLocalizedKeyAndValuesExist(in: bundle, table, for: ["strings", "stringsdict"])
    }
}
