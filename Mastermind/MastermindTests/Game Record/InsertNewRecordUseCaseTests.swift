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
    
    func test_insertNewRecord_requestRecordInsertionIfRankPositionsAvailable() {
        let (sut, store) = makeSUT()
        let ninRecords = Array(repeating: anyPlayerRecord(), count: 9)
        let record = anyPlayerRecord()
        
        store.completeRecordsRetrieval(with: ninRecords)
        try? sut.insertNewRecord(record)
        
        XCTAssertEqual(store.receivedMessages, [.loadRecords, .insert(record)])
    }
    
    func test_insertNewRecord_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let record = anyPlayerRecord()
        let insertionError = anyNSError()
        
        store.completeInsertion(with: insertionError)
        XCTAssertThrowsError(try sut.insertNewRecord(record))
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RecordLoader, RecordStoreSpy) {
        let store = RecordStoreSpy()
        let sut = RecordLoader(store: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
}
