//
//  NavigationAdapterTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/9/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest

final class GameNavigationAdapter {
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

class GameNavigationAdapterTests: XCTestCase {
    
    func test_init_doesNotNavigate() {
        let (_, nav) = makeSUT()
        
        XCTAssertTrue(nav.capturedPushes.isEmpty)
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (GameNavigationAdapter, NavigationSpy) {
        let nav = NavigationSpy()
        let sut = GameNavigationAdapter(navigationController: nav)
        
        trackForMemoryLeaks(nav, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, nav)
    }
    
    private class NavigationSpy: UINavigationController {
        var capturedPushes = [(vc: UIViewController, animated: Bool)]()
        
        override func pushViewController(_ viewController: UIViewController, animated: Bool) {
            capturedPushes.append((viewController, animated))
        }
    }
}
