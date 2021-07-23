//
//  AppDelegateTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/6/30.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
@testable import My1A2BGame

class AppDelegateTests: XCTestCase {
    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let window = UIWindow()
        let appDelegate = AppDelegate()
        appDelegate.window = window
        
        appDelegate.configureWindow()
        
        XCTAssertTrue(window.isKeyWindow)
        XCTAssertFalse(window.isHidden)
    }
    
    func test_configureWindow_configuresRootViewController() {
        let window = UIWindow()
        let appDelegate = AppDelegate()
        appDelegate.window = window
        let tabItemTitles = ["Basic", "Advanced", "Rank", "More"]
        let tabItemImageNames = ["baseline_1A2B_24px", "advanced_24px", "baseline_format_list_numbered_black_24pt", "baseline_settings_black_24pt"]
        
        appDelegate.configureWindow()
        
        let tab = window.rootViewController as! UITabBarController
        XCTAssertEqual(tab.viewControllers?.count, 4, "expect correct tab count")
        
        tab.tabBar.items!.enumerated().forEach { index, item in
            
            XCTAssertEqual(item.title, tabItemTitles[index], "expect correct tab title")
            XCTAssertEqual(item.image?.pngData(), UIImage(named: tabItemImageNames[index])?.pngData(), "expect correct tab image")
        }
    }
}
