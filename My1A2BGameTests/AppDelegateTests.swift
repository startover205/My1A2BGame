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
        
        appDelegate.configureWindow()
        
        let tab = window.rootViewController as! UITabBarController
        XCTAssertEqual(tab.viewControllers?.count, 4)
        ["Basic", "Advanced", "Rank", "More"].enumerated().forEach { index, title in
            XCTAssertEqual(tab.viewControllers?[index].title, title)
        }
    }
}
