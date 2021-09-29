//
//  RecordLocalizationTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/9/29.
//

import XCTest
import Mastermind

class RecordLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Record"
        let bundle = Bundle(for: RecordPresenter.self)
        
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
