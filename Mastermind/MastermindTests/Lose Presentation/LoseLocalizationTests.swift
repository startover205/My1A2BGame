//
//  LoseLocalizationTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/10/4.
//

import XCTest
import Mastermind

class LoseLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Lose"
        let bundle = Bundle(for: LosePresenter.self)
        
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
