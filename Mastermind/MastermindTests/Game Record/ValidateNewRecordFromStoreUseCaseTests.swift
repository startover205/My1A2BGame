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
    
    func test_validateNewRecord_requestsRecordsRetrieval() {
        let (sut, store) = makeSUT()
        let playerRecord = anyPlayerRecord()
        
        let _ = sut.validate(score: playerRecord.model.score)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateNewRecord_deliversFalseOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        let playerRecord = anyPlayerRecord()
        
        expect(sut, playerRecord.model.score, toCompleteWith: false) {
            store.completeRecordsRetrieval(with: retrievalError)
        }
    }
    
    func test_validateNewRecord_deliversTrueOnEmptyStore() {
        let (sut, store) = makeSUT()
        let emptyRecords = [LocalPlayerRecord]()
        let playerRecord = anyPlayerRecord()
        
        expect(sut, playerRecord.model.score, toCompleteWith: true) {
            store.completeRecordsRetrieval(with: emptyRecords)
        }
    }
    
    func test_validateNewRecord_deliversTrueOnRankPositionAvailable() {
        let (sut, store) = makeSUT()
        let ninePlayerRecords = Array(repeating: anyPlayerRecord().local, count: 9)
        let playerRecord = anyPlayerRecord()
        
        expect(sut, playerRecord.model.score, toCompleteWith: true) {
            store.completeRecordsRetrieval(with: ninePlayerRecords)
        }
    }
    
    func test_validateNewRecord_deliversTrueOnBeatingOldRecordWithGuessCountWhenRankPositionUnavailable() {
        let (sut, store) = makeSUT()
        let (oldRecords, _) = recordsWithOneWorstRecord()
        let newPlayerRecord = oneOfTheBestRecord()
        
        expect(sut, newPlayerRecord.model.score, toCompleteWith: true) {
            store.completeRecordsRetrieval(with: oldRecords)
        }
    }
    
    func test_validateNewRecord_deliversTrueOnBeatingOldRecordWithGuessTimeWhenRankPositionUnavailable() {
        let (sut, store) = makeSUT()
        let (oldRecords, _) = recordsWithOneWorstRecord()
        let newPlayerRecord = oneOfTheBestRecord()
        
        expect(sut, newPlayerRecord.model.score, toCompleteWith: true) {
            store.completeRecordsRetrieval(with: oldRecords)
        }
    }
    
    func test_validateNewRecord_deliversFalseOnLosingToOldRecordsWhenRankPositionUnavailable() {
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
}

private extension PlayerRecord {
    var score: Score { (guessCount, guessTime) }
}
