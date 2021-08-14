//
//  InsertNewRecordUseCaseTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/13.
//

import XCTest
import Mastermind

class InsertNewRecordUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_insertNewRecord_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let record = anyPlayerRecord()
        let retrievalError = anyNSError()
        
        store.completeRecordsRetrieval(with: retrievalError)
        try? sut.insertNewRecord(record)
        
        XCTAssertEqual(store.receivedMessages, [.loadRecords])
    }
    
    func test_insertNewRecord_doesNotInsertRecordWhenRankPositionUnavailableAndNewRecordNotBeatingOldRecords() {
        let (sut, store) = makeSUT()
        let oldRecords = Array(repeating: oneOfTheBestRecord(), count: 10)
        let newPlayerRecord = oneWorstRecord()
        
        store.completeRecordsRetrieval(with: oldRecords)
        try? sut.insertNewRecord(newPlayerRecord)
        
        XCTAssertEqual(store.receivedMessages, [.loadRecords])
    }
    
    func test_insertNewRecord_doesNotInsertRecordOnDeletionErrorWhenRankPositionUnavailableAndBeatingOldRecords() {
        let (sut, store) = makeSUT()
        let (oldRecords, worstRecord) = recordsWithOneWorstRecord()
        let newPlayerRecord = oneOfTheBestRecord()
        let deletionError = anyNSError()
        
        store.completeRecordsRetrieval(with: oldRecords)
        store.completeDeletion(with: deletionError)
        try? sut.insertNewRecord(newPlayerRecord)
        
        XCTAssertEqual(store.receivedMessages, [.loadRecords, .delete([worstRecord])])
    }
    
    func test_insertNewRecord_requestRecordInsertionIfRankPositionUnavailableAndBeatingOldRecords() {
        let (sut, store) = makeSUT()
        let (oldRecords, worstRecord) = recordsWithOneWorstRecord()
        let newPlayerRecord = oneOfTheBestRecord()
        
        store.completeRecordsRetrieval(with: oldRecords)
        try? sut.insertNewRecord(newPlayerRecord)
        
        XCTAssertEqual(store.receivedMessages, [.loadRecords, .delete([worstRecord]), .insert(newPlayerRecord)])
    }
    
    func test_insertNewRecord_requestRecordInsertionIfRankPositionsAvailable() {
        let (sut, store) = makeSUT()
        let ninRecords = Array(repeating: anyPlayerRecord(), count: 9)
        let record = anyPlayerRecord()
        
        store.completeRecordsRetrieval(with: ninRecords)
        try? sut.insertNewRecord(record)
        
        XCTAssertEqual(store.receivedMessages, [.loadRecords, .insert(record)])
    }
    
    func test_insertNewRecord_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let record = anyPlayerRecord()
        let retrievalError = anyNSError()
        
        expect(sut, newRecord: record, toCompleteWithError: retrievalError) {
            store.completeRecordsRetrieval(with: retrievalError)
        }
    }
    
    func test_insertNewRecord_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let (oldRecords, _) = recordsWithOneWorstRecord()
        let newPlayerRecord = oneOfTheBestRecord()
        let deletionError = anyNSError()
        
        expect(sut, newRecord: newPlayerRecord, toCompleteWithError: deletionError) {
            store.completeRecordsRetrieval(with: oldRecords)
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_insertNewRecord_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let record = anyPlayerRecord()
        let emptyRecords = [PlayerRecord]()
        let insertionError = anyNSError()
        
        expect(sut, newRecord: record, toCompleteWithError: insertionError) {
            store.completeRecordsRetrieval(with: emptyRecords)
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_insertNewRecord_successfullyInsertNewReocrd() {
        let (sut, store) = makeSUT()
        let record = anyPlayerRecord()
        let emptyRecords = [PlayerRecord]()
        
        expect(sut, newRecord: record, toCompleteWithError: nil) {
            store.completeRecordsRetrieval(with: emptyRecords)
            store.completeInsertionSuccessfully()
        }
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RecordLoader, RecordStoreSpy) {
        let store = RecordStoreSpy()
        let sut = RecordLoader(store: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: RecordLoader, newRecord: PlayerRecord, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        action()
        
        do {
            try sut.insertNewRecord(newRecord)
        } catch {
            XCTAssertEqual(error as NSError?, expectedError, file: file, line: line)
        }
    }
}
