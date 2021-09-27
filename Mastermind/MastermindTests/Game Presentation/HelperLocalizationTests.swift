//
//  HelperLocalizationTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/9/27.
//

import XCTest
import Mastermind

class HelperLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Helper"
        let bundle = Bundle(for: HelperPresenter.self)
        
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
