//
//  NavigationAdapterTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/9/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import Mastermind
import My1A2BGame

class GameNavigationAdapterTests: XCTestCase {
    
    func test_init_doesNotNavigate() {
        let (_, nav) = makeSUT()
        
        XCTAssertTrue(nav.receivedMessages.isEmpty)
    }
    
    func test_acceptGuessTwice_setsChallengeViewControllerWithoutAnimationOnce() {
        let challengeController = UIViewController()
        let (sut, nav) = makeSUT(gameComposer: {_ in
            return challengeController
        })
        
        sut.acceptGuess { _ in (nil, false)}
        sut.acceptGuess { _ in (nil, false)}
        
        XCTAssertEqual(nav.receivedMessages, [.set(viewControllers: [challengeController], animated: false)])
    }
    
    func test_acceptGuess_requestGameComposerToHandleGuessCompletion() {
        var capturedGuess: DigitSecret?
        let challengeController = UIViewController()
        let digitSecret = anyDigitSecret()
        let (sut, _) = makeSUT(gameComposer: { guessCompletion in
            _ = guessCompletion(digitSecret)
            return challengeController
        })
        
        sut.acceptGuess { guess in
            capturedGuess = guess
            return (nil, false)
        }
        
        XCTAssertEqual(capturedGuess, digitSecret)
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
    
    func test_replenishChanceTwice_requestDelegateToReplenishChanceTwice() {
        var capturedChanceCount: Int?
        let delegate = ReplenishChanceDelegateSpy()
        let (sut, _) = makeSUT(delegate: delegate)
        let completion: (Int) -> Void = { chanceCount in
            capturedChanceCount = chanceCount
        }
        
        sut.replenishChance(completion: completion)
        delegate.completions[0](1)
        
        XCTAssertEqual(capturedChanceCount, 1)
        
        sut.replenishChance(completion: completion)
        delegate.completions[1](0)
        XCTAssertEqual(capturedChanceCount, 0)
    }
    
    // MARK: Helpers
    
    private func makeSUT(gameComposer: @escaping (GuessCompletion) -> UIViewController = { _ in UIViewController() }, winComposer: @escaping () -> UIViewController = { UIViewController() }, loseComposer: @escaping () -> UIViewController = { UIViewController() }, delegate: ReplenishChanceDelegate = ReplenishChanceDelegateSpy(), file: StaticString = #filePath, line: UInt = #line) -> (GameNavigationAdapter, NavigationSpy) {
        let nav = NavigationSpy()
        let sut = GameNavigationAdapter(navigationController: nav, gameComposer: gameComposer, winComposer: winComposer, loseComposer: loseComposer, delegate: delegate)
        
        trackForMemoryLeaks(nav, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, nav)
    }
    
    private func anyDigitSecret() -> DigitSecret {
        DigitSecret(digits: [])!
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
    
    private class ReplenishChanceDelegateSpy: ReplenishChanceDelegate {
        var completions = [(Int) -> Void]()
        
        func replenishChance(completion: @escaping (Int) -> Void) {
            completions.append(completion)
        }
    }
}
