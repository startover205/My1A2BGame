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
        
        delegate.completeGuess(with: "a correct guess")
         
        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess, .showHint("a hint about the successful match"), .handleWin])
    }
    
    func test_startChallenge_losesChallengeWithProperHint() {
        let (sut, delegate) = makeSUT(maxChanceCount: 1, matchGuess:  { _, _ in
            return ("a hint about the failing match", false)
        })
        self.sut = sut
        
        delegate.completeGuess(with: "an incorrect guess")
        delegate.completeReplenish(with: 0)
         
        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess, .showHint("a hint about the failing match"), .replenishChance, .handleLose])
    }
    
    // MARK: Helpers
    
    private func makeSUT(maxChanceCount: Int, matchGuess: @escaping GuessMatcher<DelegateSpy, String>, file: StaticString = #filePath, line: UInt = #line) -> (Challenge, DelegateSpy) {
        let delegate = DelegateSpy()
        let sut = Challenge.start(secret: "", maxChanceCount: maxChanceCount, matchGuess: matchGuess, delegate: delegate)

        trackForMemoryLeaks(delegate, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, delegate)
    }
}
