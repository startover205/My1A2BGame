//
//  RewardAdLocalizationTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/9/28.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame

class RewardAdLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "RewardAd"
        let bundle = Bundle(for: RewardAdPresenter.self)
        
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
