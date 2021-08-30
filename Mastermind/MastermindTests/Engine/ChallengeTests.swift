//
//  ChallengeTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/25.
//

import XCTest
import Mastermind

class ChallengeTests: XCTestCase {
    
    private weak var sut: Challenge?
    
    func test_startChallenge_winsChallengeWithProperHint() {
        let (sut, delegate) = makeSUT(maxChanceCount: 1, matchGuess:  { _, _ in
            return ("a hint about the successful match", true)
        })
        self.sut = sut
        
        let hint = delegate.completeGuess(with: "a correct guess")
        
        XCTAssertEqual(hint, "a hint about the successful match")
        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess, .handleWin])
    }
    
    func test_startChallenge_losesChallengeWithProperHint() {
        let (sut, delegate) = makeSUT(maxChanceCount: 1, matchGuess:  { _, _ in
            return ("a hint about the failing match", false)
        })
        self.sut = sut
        
        let hint = delegate.completeGuess(with: "an incorrect guess")
        
        XCTAssertEqual(hint, "a hint about the failing match")
        
        delegate.completeReplenish(with: 0)
        
        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess, .replenishChance, .handleLose])
    }
    
    // MARK: Helpers
    
    private func makeSUT(maxChanceCount: Int, matchGuess: @escaping GuessMatcher<DelegateSpy, String>, file: StaticString = #filePath, line: UInt = #line) -> (Challenge, DelegateSpy) {
        let delegate = DelegateSpy()
        let sut = Challenge.start(secret: "", maxChanceCount: maxChanceCount, matchGuess: matchGuess as (DelegateSpy.Guess, String) -> (hint: DelegateSpy.Hint?, correct: Bool), delegate: delegate)

        trackForMemoryLeaks(delegate, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, delegate)
    }
}
