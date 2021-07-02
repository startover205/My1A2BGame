//
//  GameUITests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/7/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame

class GameUITests: XCTestCase {
    func test_onLaunch_hasTabsSetup() {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssertEqual(app.tabBars.firstMatch.buttons.count, 4)
        XCTAssertEqual(app.tabBars.firstMatch.buttons.element(boundBy: 0).label, "Basic")
        XCTAssertEqual(app.tabBars.firstMatch.buttons.element(boundBy: 1).label, "Advanced")
        XCTAssertEqual(app.tabBars.firstMatch.buttons.element(boundBy: 2).label, "Rank")
        XCTAssertEqual(app.tabBars.firstMatch.buttons.element(boundBy: 3).label, "More")
    }
}
