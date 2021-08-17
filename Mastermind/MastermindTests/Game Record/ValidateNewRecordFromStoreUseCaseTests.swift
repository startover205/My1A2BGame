//
//  ValidateNewRecordFromStoreUseCaseTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/13.
//

import XCTest
import Mastermind

class ValidateNewRecordFromStoreUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validate_requestsRecordsRetrieval() {
        let (sut, store) = makeSUT()
        let score = anyScore()

        let _ = sut.validate(score: score)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validate_deliversFalseOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        let score = anyScore()

        expect(sut, score, toCompleteWith: false) {
            store.completeRecordsRetrieval(with: retrievalError)
        }
    }
    
    func test_validate_deliversTrueOnEmptyStore() {
        let (sut, store) = makeSUT()
        let emptyRecords = [LocalPlayerRecord]()
        let score = anyScore()

        expect(sut, score, toCompleteWith: true) {
            store.completeRecordsRetrieval(with: emptyRecords)
        }
    }
    
    func test_validate_deliversTrueOnRankPositionAvailable() {
        let (sut, store) = makeSUT()
        let ninePlayerRecords = Array(repeating: anyPlayerRecord().local, count: 9)
        let score = anyScore()
        
        expect(sut, score, toCompleteWith: true) {
            store.completeRecordsRetrieval(with: ninePlayerRecords)
        }
    }
    
    func test_validate_deliversTrueOnBeatingOldRecordWithGuessCountWhenRankPositionUnavailable() {
        let (sut, store) = makeSUT()
        let guessCount = 2
        let guessTime = 10.0
        let oldRecords = Array(repeating: LocalPlayerRecord(playerName: "a name", guessCount: guessCount, guessTime: guessTime, timestamp: Date()), count: 10)
        let score = (guessCount-1, guessTime)
        
        expect(sut, score, toCompleteWith: true) {
            store.completeRecordsRetrieval(with: oldRecords)
        }
    }
    
    func test_validate_deliversTrueOnBeatingOldRecordWithGuessTimeWhenRankPositionUnavailable() {
        let (sut, store) = makeSUT()
        let guessCount = 2
        let guessTime = 10.0
        let oldRecords = Array(repeating: LocalPlayerRecord(playerName: "a name", guessCount: guessCount, guessTime: guessTime, timestamp: Date()), count: 10)
        let score = (guessCount, guessTime-1)

        expect(sut, score, toCompleteWith: true) {
            store.completeRecordsRetrieval(with: oldRecords)
        }
    }
    
    func test_validate_deliversFalseOnLosingToOldRecordsWhenRankPositionUnavailable() {
        let (sut, store) = makeSUT()
        let oldRecords = Array(repeating: oneOfTheBestRecord().local, count: 10)
        let newPlayerRecord = oneWorstRecord()
        
        expect(sut, newPlayerRecord.model.score, toCompleteWith: false) {
            store.completeRecordsRetrieval(with: oldRecords)
        }
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalRecordLoader, RecordStoreSpy) {
        let store = RecordStoreSpy()
        let sut = LocalRecordLoader(store: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalRecordLoader, _ score: Score, toCompleteWith expectedResult: Bool, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        action()
        
        let receivedResult = sut.validate(score: score)
        
        XCTAssertEqual(receivedResult, expectedResult, file: file, line: line)
    }
    
    private func anyScore() -> Score { (2, 5.0) }
}

private extension PlayerRecord {
    var score: Score { (guessCount, guessTime) }
}
