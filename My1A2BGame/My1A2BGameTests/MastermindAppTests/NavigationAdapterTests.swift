//
//  NavigationAdapterTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/9/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import Mastermind

final class GameNavigationAdapter {
    let navigationController: UINavigationController
    let challengeComposer: () -> UIViewController
    let winComposer: () -> UIViewController
    let loseComposer: () -> UIViewController

    init(navigationController: UINavigationController, challengeComposer: @escaping () -> UIViewController, winComposer: @escaping () -> UIViewController, loseComposer: @escaping () -> UIViewController) {
        self.navigationController = navigationController
        self.challengeComposer = challengeComposer
        self.winComposer = winComposer
        self.loseComposer = loseComposer
    }
    
    func acceptGuess() {
        navigationController.setViewControllers([challengeComposer()], animated: false)
    }
    
    func didWin() {
        navigationController.pushViewController(winComposer(), animated: true)
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
    
    func test_acceptGuess_setsChallengeViewControllerWithoutAnimation() {
        let challengeController = UIViewController()
        let (sut, nav) = makeSUT(challengeComposer: {
            return challengeController
        })
        
        sut.acceptGuess()
        
        XCTAssertEqual(nav.receivedMessages, [.set(viewControllers: [challengeController], animated: false)])
    }
    
    func test_didWin_pushesWinControllerWithAnimation() {
        let winController = UIViewController()
        let (sut, nav) = makeSUT(winComposer: {
            return winController
        })
        
        sut.didWin()
        
        XCTAssertEqual(nav.receivedMessages, [.push(viewController: winController,animated: true)])
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
    
    private func makeSUT(challengeComposer: @escaping () -> UIViewController = { UIViewController() }, winComposer: @escaping () -> UIViewController = { UIViewController() }, loseComposer: @escaping () -> UIViewController = { UIViewController() }, file: StaticString = #filePath, line: UInt = #line) -> (GameNavigationAdapter, NavigationSpy) {
        let nav = NavigationSpy()
        let sut = GameNavigationAdapter(navigationController: nav, challengeComposer: challengeComposer, winComposer: winComposer, loseComposer: loseComposer)
        
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
