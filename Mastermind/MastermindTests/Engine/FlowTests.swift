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
    
    func test_start_withNoChances_requestDelegateToHandleLoseWithEmptyHint() {
        let (sut, delegate) = makeSUT(maxChanceCount: 0)

        sut.start()

        XCTAssertEqual(delegate.receivedMessages, [.handleLose(nil)])
    }

    func test_start_withOneChance_requestDelegateToAcceptGuessWithEmptyHint() {
        let (sut, delegate) = makeSUT(maxChanceCount: 1)

        sut.start()

        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess(nil)])
    }

    func test_start_withTwoChances_requestDelegateToAcceptGuessWithEmptyHint() {
        let (sut, delegate) = makeSUT(maxChanceCount: 2)

        sut.start()

        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess(nil)])
    }

    func test_startTwice_withTwoChances_requestDelegateToAcceptGuessWithEmptyHintTwice() {
        let (sut, delegate) = makeSUT(maxChanceCount: 2)

        sut.start()
        sut.start()

        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess(nil), .acceptGuess(nil)])
    }

    func test_startAndGuessTwiceWithWrongAnswer_withThreeChances_requestDelegateToAcceptGuessWithProperHint() {
        let (sut, delegate) = makeSUT(maxChanceCount: 3) { _, _ in
            return ("a hint", false)
        }

        sut.start()

        delegate.completions[0]("a guess")
        delegate.completions[1]("another guess")

        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess(nil), .acceptGuess("a hint"), .acceptGuess("a hint")])
    }

    func test_startAndGuessTwiceWithWrongAnswer_withTwoChances_requestDelegateToPresentLoseWithProperHint() {
        let (sut, delegate) = makeSUT(maxChanceCount: 2) { _, _ in
            return ("a hint", false)
        }

        sut.start()

        delegate.completions[0]("a guess")
        delegate.completions[1]("another guess")

        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess(nil), .acceptGuess("a hint"), .handleLose("a hint")])
    }

    func test_startAndGuessWithRighAnswer_withOneChance_requestDelegateToHandleResultWithProperHint() {
        let (sut, delegate) = makeSUT(maxChanceCount: 1) { _, _ in
            return ("a hint", true)
        }

        sut.start()

        delegate.completions[0]("right guess")

        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess(nil), .handleWin("a hint")])
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
