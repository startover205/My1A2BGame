//
//  FlowTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/24.
//


import XCTest
@testable import Mastermind

class FlowTests: XCTestCase {
    
    func test_init_doesNotRequestDelegateUponCreation() {
        let (_, delegate) = makeSUT()

        XCTAssertTrue(delegate.receivedMessages.isEmpty)
    }
    
    func test_start_withNoChances_requestDelegateToReplenishChances() {
        let (sut, delegate) = makeSUT(maxChanceCount: 0)

        sut.start()

        XCTAssertEqual(delegate.receivedMessages, [.replenishChance])
    }
    
    func test_start_withNoChances_withNoReplenish_requestDelegateToHandleLose() {
        let (sut, delegate) = makeSUT(maxChanceCount: 0)

        sut.start()
        
        delegate.completeReplenish(with: 0)
        
        XCTAssertEqual(delegate.receivedMessages, [.replenishChance, .handleLose])
    }

    func test_start_withOneChance_requestDelegateToAcceptGuessWithEmptyHint() {
        let (sut, delegate) = makeSUT(maxChanceCount: 1)

        sut.start()

        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess])
    }

    func test_start_withTwoChances_requestDelegateToAcceptGuessWithEmptyHint() {
        let (sut, delegate) = makeSUT(maxChanceCount: 2)

        sut.start()

        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess])
    }

    func test_startTwice_withTwoChances_requestDelegateToAcceptGuessWithEmptyHintTwice() {
        let (sut, delegate) = makeSUT(maxChanceCount: 2)

        sut.start()
        sut.start()

        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess, .acceptGuess])
    }

    func test_startAndGuess_withOneChance_requestsMatchWithRightGuessAndSecret() {
        let secret = "a secret"
        let guess = "a guess"
        var capturedSecret: String?
        var capturedGuess: String?
        let (sut, delegate) = makeSUT(maxChanceCount: 1, secret: secret) { guess, secret in
            capturedSecret = secret
            capturedGuess = guess
            return ("a hint", false)
        }

        sut.start()

        _ = delegate.completeGuess(with: guess)

        XCTAssertEqual(capturedSecret, secret)
        XCTAssertEqual(capturedGuess, guess)
    }

    func test_startAndGuess_withOneChance_deliversProperHint() {
        let (sut, delegate) = makeSUT(maxChanceCount: 1) { guess, secret in
            return ("a hint", false)
        }

        sut.start()

        let hint = delegate.completeGuess(with: "a guess")

        XCTAssertEqual(hint, "a hint")
    }
    
    func test_startAndGuessTwiceWithWrongAnswer_withThreeChances_requestDelegateToAcceptGuessWithProperHint() {
        let (sut, delegate) = makeSUT(maxChanceCount: 3) { _, _ in
            return ("a hint", false)
        }

        sut.start()

        _ = delegate.completeGuess(with: "a guess", at: 0)
        _ = delegate.completeGuess(with: "another guess", at: 1)

        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess, .acceptGuess, .acceptGuess])
    }

    func test_startAndGuessTwiceWithWrongAnswer_withTwoChances_withNoReplenish_requestDelegateToPresentLoseWithProperHint() {
        let (sut, delegate) = makeSUT(maxChanceCount: 2) { _, _ in
            return ("a hint about why it fails", false)
        }

        sut.start()

        _ = delegate.completeGuess(with: "an incorrect guess", at: 0)
        _ = delegate.completeGuess(with: "another incorrect guess", at: 1)
        delegate.completeReplenish(with: 0)

        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess, .acceptGuess, .replenishChance, .handleLose])
    }

    func test_startAndGuessWithRighAnswer_withOneChance_requestDelegateToHandleResultWithProperHint() {
        let (sut, delegate) = makeSUT(maxChanceCount: 1) { _, _ in
            return ("a hint about a successful match", true)
        }

        sut.start()

        _ = delegate.completeGuess(with: "a correct guess")

        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess, .handleWin])
    }
    
    func test_startAndGuessWithWrongAnswer_withOneChance_withOneReplenishedChance_requestDelegateToAcceptGuessAgainAfterReplenish() {
        let (sut, delegate) = makeSUT(maxChanceCount: 1) { _, _ in
            return ("a hint about why it fails", false)
        }

        sut.start()

        _ = delegate.completeGuess(with: "an incorrect guess")
        delegate.completeReplenish(with: 1)

        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess, .replenishChance, .acceptGuess])
    }

    func test_startAndGuessWithWrongAnswerTwiceAndCorrectAnswerOnThirdTry_withOneChance_withOneReplenishedChanceTwice_requestDelegateToHandleWin() {
        let (sut, delegate) = makeSUT(maxChanceCount: 1, secret: "a correct guess") { guess, secret in
            if guess == secret {
                return ("a hint about the successful match", true)
            } else {
                return ("a hint about the failing match", false)
            }
        }

        sut.start()

        _ = delegate.completeGuess(with: "an incorrect guess", at: 0)
        delegate.completeReplenish(with: 1, at: 0)
        _ = delegate.completeGuess(with: "an incorrect guess", at: 1)
        delegate.completeReplenish(with: 1, at: 1)
        _ = delegate.completeGuess(with: "a correct guess", at: 2)

        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess,  .replenishChance, .acceptGuess, .replenishChance, .acceptGuess, .handleWin])
    }

    
    // MARK: Helpers
    
    private func makeSUT(maxChanceCount: Int = 0, secret: String = "1234", matchGuess: @escaping GuessMatcher<DelegateSpy, String> = { _, _ in return  (nil, false) }, file: StaticString = #filePath, line: UInt = #line) -> (Flow<DelegateSpy, String>, DelegateSpy) {
        let delegate = DelegateSpy()
        let sut = Flow(maxChanceCount: maxChanceCount, secret: secret, matchGuess: matchGuess, delegate: delegate)
        
        trackForMemoryLeaks(delegate, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, delegate)
    }
}
