//
//  RankLocalizationTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/10/14.
//

import XCTest
import Mastermind

class RankLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Rank"
        let bundle = Bundle(for: RankPresenter.self)
        
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
