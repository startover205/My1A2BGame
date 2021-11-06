//
//  AppDelegateTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/6/30.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import MastermindiOS
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
    
    func test_configureWindow_configureTabBarWithAd() {
        let window = UIWindow()
        let appDelegate = AppDelegate()
        appDelegate.window = window
        
        appDelegate.configureWindow()
        
        XCTAssertNotNil(window.rootViewController as? BannerAdTabBarViewController)
    }
    
    func test_configureWindow_configuresTabs() throws {
        let window = UIWindow()
        let appDelegate = AppDelegate()
        appDelegate.window = window
        let tabItemTitles = ["Basic", "Advanced", "Rank", "More"]
        let tabItemImageNames = ["baseline_1A2B_24px", "advanced_24px", "baseline_format_list_numbered_black_24pt", "baseline_settings_black_24pt"]
        
        appDelegate.configureWindow()
        
        let tab = try XCTUnwrap(window.rootViewController as? UITabBarController)
        XCTAssertEqual(tab.viewControllers?.count, 4, "Expect correct tab count")
        
        tab.tabBar.items!.enumerated().forEach { index, item in
            XCTAssertEqual(item.title, tabItemTitles[index], "Expect tab title \(tabItemTitles[index]) at \(index), got \(String(describing: item.title)) instead")
            XCTAssertEqual(item.image?.pngData(), UIImage(named: tabItemImageNames[index])?.pngData(), "Expect correct tab image at \(index)")
        }
        
        XCTAssertTrue(tab.viewControllers?[0].embedViewController() is GuessNumberViewController, "Expect GuessNumberViewController at tab index 0")
        XCTAssertTrue(tab.viewControllers?[1].embedViewController() is GuessNumberViewController, "Expect GuessNumberViewController at tab index 1")
        XCTAssertTrue(tab.viewControllers?[2].embedViewController() is RankViewController, "Expect RankViewController at tab index 2")
        XCTAssertTrue(tab.viewControllers?[3].embedViewController() is MoreViewController, "Expect MoreViewController at tab index 3")
    }
}

private extension UIViewController {
    func embedViewController() -> UIViewController? {
        (self as? UINavigationController)?.topViewController
    }
}
