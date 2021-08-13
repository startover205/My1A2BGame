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

        let _ = sut.validateNewRecord(with: playerRecord)
        
        XCTAssertEqual(store.receivedMessages, [.loadRecords])
    }
    
    func test_validateNewRecord_deliversFalseOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        let playerRecord = anyPlayerRecord()

        store.completeRecordsRetrieval(with: retrievalError)
        let result = sut.validateNewRecord(with: playerRecord)
        
        XCTAssertFalse(result)
    }
    
    func test_validateNewRecord_deliversTrueOnEmptyStore() {
        let (sut, store) = makeSUT()
        let emptyRecords = [PlayerRecord]()
        let playerRecord = anyPlayerRecord()
        
        store.completeRecordsRetrieval(with: emptyRecords)
        let result = sut.validateNewRecord(with: playerRecord)
        
        XCTAssertTrue(result)
    }
    
    func test_validateNewRecord_deliversTrueOnRankPlaceAvailable() {
        let (sut, store) = makeSUT()
        let ninePlayerRecords = Array(repeating: anyPlayerRecord(), count: 9)
        let playerRecord = anyPlayerRecord()
        
        store.completeRecordsRetrieval(with: ninePlayerRecords)
        let result = sut.validateNewRecord(with: playerRecord)
        
        XCTAssertTrue(result)
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RecordLoader, RecordStoreSpy) {
        let store = RecordStoreSpy()
        let sut = RecordLoader(store: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func anyPlayerRecord() -> PlayerRecord {
        PlayerRecord(playerName: "a name", guessCount: 10, guessTime: 10)
    }
    
}
