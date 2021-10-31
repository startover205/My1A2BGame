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
        try? sut.insertNewRecord(record.model)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_insertNewRecord_doesNotInsertRecordWhenRankPositionUnavailableAndNewRecordNotBeatingOldRecords() throws {
        let (sut, store) = makeSUT()
        let oldRecords = Array(repeating: oneOfTheBestRecord().local, count: 10)
        let newPlayerRecord = oneWorstRecord()
        
        store.completeRecordsRetrieval(with: oldRecords)
        try sut.insertNewRecord(newPlayerRecord.model)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_insertNewRecord_doesNotInsertRecordOnDeletionErrorWhenRankPositionUnavailableAndBeatingOldRecords() {
        let (sut, store) = makeSUT()
        let (oldRecords, worstRecord) = recordsWithOneWorstRecord()
        let newPlayerRecord = oneOfTheBestRecord()
        let deletionError = anyNSError()
        
        store.completeRecordsRetrieval(with: oldRecords)
        store.completeDeletion(with: deletionError)
        try? sut.insertNewRecord(newPlayerRecord.model)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .delete([worstRecord])])
    }
    
    func test_insertNewRecord_requestRecordInsertionIfRankPositionUnavailableAndBeatingOldRecords() throws {
        let (sut, store) = makeSUT()
        let (oldRecords, worstRecord) = recordsWithOneWorstRecord()
        let newPlayerRecord = oneOfTheBestRecord()
        
        store.completeRecordsRetrieval(with: oldRecords)
        try sut.insertNewRecord(newPlayerRecord.model)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .delete([worstRecord]), .insert(newPlayerRecord.local)])
    }
    
    func test_insertNewRecord_requestRecordInsertionIfRankPositionsAvailable() throws {
        let (sut, store) = makeSUT()
        let nineExistingRecords = Array(repeating: anyPlayerRecord().local, count: 9)
        let record = anyPlayerRecord()
        
        store.completeRecordsRetrieval(with: nineExistingRecords)
        try sut.insertNewRecord(record.model)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .insert(record.local)])
    }
    
    func test_insertNewRecord_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let record = anyPlayerRecord()
        let retrievalError = anyNSError()
        
        expect(sut, newRecord: record.model, toCompleteWithError: retrievalError) {
            store.completeRecordsRetrieval(with: retrievalError)
        }
    }
    
    func test_insertNewRecord_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let (oldRecords, _) = recordsWithOneWorstRecord()
        let newPlayerRecord = oneOfTheBestRecord()
        let deletionError = anyNSError()
        
        expect(sut, newRecord: newPlayerRecord.model, toCompleteWithError: deletionError) {
            store.completeRecordsRetrieval(with: oldRecords)
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_insertNewRecord_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let record = anyPlayerRecord()
        let emptyRecords = [LocalPlayerRecord]()
        let insertionError = anyNSError()
        
        expect(sut, newRecord: record.model, toCompleteWithError: insertionError) {
            store.completeRecordsRetrieval(with: emptyRecords)
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_insertNewRecord_successfullyInsertNewReocrd() {
        let (sut, store) = makeSUT()
        let record = anyPlayerRecord()
        let emptyRecords = [LocalPlayerRecord]()
        
        expect(sut, newRecord: record.model, toCompleteWithError: nil) {
            store.completeRecordsRetrieval(with: emptyRecords)
            store.completeInsertionSuccessfully()
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
    
    private func expect(_ sut: LocalRecordLoader, newRecord: PlayerRecord, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        action()
        
        do {
            try sut.insertNewRecord(newRecord)
        } catch {
            XCTAssertEqual(error as NSError?, expectedError, file: file, line: line)
        }
    }
}
