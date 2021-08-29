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
        let (sut, delegate) = makeSUT(maxChanceCount: 2, matchGuess:  { _, _ in
            return ("a hint about the successful match", true)
        })
        self.sut = sut
        
        delegate.completions[0]("a correct guess")
         
        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess(nil), .handleWin("a hint about the successful match")])
    }
    
    func test_startChallenge_losesChallengeWithProperHint() {
        let (sut, delegate) = makeSUT(maxChanceCount: 2, matchGuess:  { _, _ in
            return ("a hint about the failing match", false)
        })
        self.sut = sut
        
        delegate.completions[0]("an incorrect guess")
        delegate.completions[1]("another incorrect guess")
         
        XCTAssertEqual(delegate.receivedMessages, [.acceptGuess(nil), .acceptGuess("a hint about the failing match"), .handleLose("a hint about the failing match")])
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
