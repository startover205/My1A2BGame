//
//  GameLocalizationTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/9/23.
//

import XCTest
import Mastermind

class GameLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Game"
        let bundle = Bundle(for: GamePresenter.self)
        
        assertLocalizedKeyAndValuesExist(in: bundle, table, for: ["strings", "stringsdict"])
    }
}
