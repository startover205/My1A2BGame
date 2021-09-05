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
    
    func test_acceptGuessTwice_requestsGameComposerToHandleGuessCompletionTwice() {
        var capturedGuesses = [DigitSecret]()
        let challengeController = UIViewController()
        let digitSecret = anyDigitSecret()
        let (sut, _) = makeSUT(gameComposer: { guessCompletion in
            _ = guessCompletion(digitSecret)
            return challengeController
        })
        
        let guessCompletion: GuessCompletion = { guess in
            capturedGuesses.append(guess)
            return (nil, false)
        }
        sut.acceptGuess(completion: guessCompletion)
        sut.acceptGuess(completion: guessCompletion)

        XCTAssertEqual(capturedGuesses, [digitSecret, digitSecret])
    }
    
    func test_didWin_pushesWinControllerWithDefaultScoreWithAnimation() {
        let winController = UIViewController()
        let score: Score = (0, 0.0)
        var capturedScore: Score?
        let (sut, nav) = makeSUT(winComposer: { score in
            capturedScore = score
            return winController
        })
        
        sut.didWin()
        
        XCTAssertEqual(nav.receivedMessages, [.push(viewController: winController,animated: true)])
        XCTAssertEqual(capturedScore?.guessCount, score.guessCount)
        XCTAssertEqual(capturedScore?.guessTime, score.guessTime)
    }
    
    func test_didWinAfterTwoGuessesAndTwoMinutes_pushesWinControllerWithProperScoreWithAnimation() {
        let gameController = UIViewController()
        let winController = UIViewController()
        let score: Score = (2, 120.0)
        var startTime = 0.0
        var capturedScore: Score?
        let (sut, nav) = makeSUT(
            gameComposer: { _ in gameController },
            winComposer: { score in
                capturedScore = score
                return winController
            },
            currentDeviceTime: {
                let currentTime = startTime
                startTime += 120.0
                return currentTime
            })
        
        sut.acceptGuess { _ in (nil, false) }
        sut.acceptGuess { _ in (nil, true) }
        
        sut.didWin()
        
        XCTAssertEqual(nav.receivedMessages, [
                        .set(viewControllers: [gameController], animated: false),
                        .push(viewController: winController,animated: true)])
        XCTAssertEqual(capturedScore?.guessCount, score.guessCount)
        XCTAssertEqual(capturedScore?.guessTime, score.guessTime)
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
    
    private func makeSUT(gameComposer: @escaping (GuessCompletion) -> UIViewController = { _ in UIViewController() }, winComposer: @escaping (Score) -> UIViewController = { _ in UIViewController() }, loseComposer: @escaping () -> UIViewController = { UIViewController() }, delegate: ReplenishChanceDelegate = ReplenishChanceDelegateSpy(), currentDeviceTime: @escaping () -> TimeInterval = CACurrentMediaTime, file: StaticString = #filePath, line: UInt = #line) -> (GameNavigationAdapter, NavigationSpy) {
        let nav = NavigationSpy()
        let sut = GameNavigationAdapter(navigationController: nav, gameComposer: gameComposer, winComposer: winComposer, loseComposer: loseComposer, delegate: delegate, currentDeviceTime: currentDeviceTime)
        
        trackForMemoryLeaks(nav, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, nav)
    }
    
    private func anyDigitSecret() -> DigitSecret {
        DigitSecret(digits: [])!
    }
    
    private func anyScore() -> Score {
        (1, 10.0)
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
