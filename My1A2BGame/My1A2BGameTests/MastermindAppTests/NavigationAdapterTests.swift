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
    let loseComposer: () -> UIViewController

    init(navigationController: UINavigationController, loseComposer: @escaping () -> UIViewController) {
        self.navigationController = navigationController
        self.loseComposer = loseComposer
    }
    
    func didLose() {
        navigationController.pushViewController(loseComposer(), animated: true)
    }
}

class GameNavigationAdapterTests: XCTestCase {
    
    func test_init_doesNotNavigate() {
        let (_, nav) = makeSUT()
        
        XCTAssertTrue(nav.receivedMessages.isEmpty)
    }
    
    func test_didLose_pushesLoseControllerWithAnimation() {
        let loseController = UIViewController()
        let (sut, nav) = makeSUT(loseComposer: {
            return loseController
        })
        
        sut.didLose()
        
        XCTAssertEqual(nav.receivedMessages, [.push(viewController: loseController,animated: true)])
    }
    

    
    // MARK: Helpers
    
    private func makeSUT(loseComposer: @escaping () -> UIViewController = { UIViewController() }, file: StaticString = #filePath, line: UInt = #line) -> (GameNavigationAdapter, NavigationSpy) {
        let nav = NavigationSpy()
        let sut = GameNavigationAdapter(navigationController: nav, loseComposer: loseComposer)
        
        trackForMemoryLeaks(nav, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, nav)
    }
    
    private class NavigationSpy: UINavigationController {
        enum Message: Equatable {
            case push(viewController: UIViewController, animated: Bool)
            case set(viewControllers: [UIViewController], animated: Bool)
        }
        
        private(set) var receivedMessages = [Message]()
        
        override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
            receivedMessages.append(.set(viewControllers: viewControllers, animated: animated))
        }
        
        override func pushViewController(_ viewController: UIViewController, animated: Bool) {
            receivedMessages.append(.push(viewController: viewController, animated: animated))
        }
    }
}
