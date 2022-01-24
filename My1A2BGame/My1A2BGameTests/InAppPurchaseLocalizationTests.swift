//
//  InAppPurchaseLocalizationTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/12/24.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame

class InAppPurchaseLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "InAppPurchase"
        let bundle = Bundle(for: ProductPresenter.self)
        
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
