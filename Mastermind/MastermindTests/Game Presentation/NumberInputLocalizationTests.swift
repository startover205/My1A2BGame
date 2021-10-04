//
//  NumberInputLocalizationTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/10/4.
//

import XCTest
import Mastermind

class NumberInputLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "NumberInput"
        let bundle = Bundle(for: NumberInputPresenter.self)
        
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
