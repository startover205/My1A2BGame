//
//  RecordLoaderTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/13.
//

import XCTest
import Mastermind

class LoadRecordsFromStoreUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestRecordsRetrieval() throws {
        let (sut, store) = makeSUT()
        
        _ = try sut.load()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        store.completeRecordsRetrieval(with: retrievalError)
        
        XCTAssertThrowsError(try sut.load())
    }
    
    func test_load_returnsNoRecordsOnEmptyStore() throws {
        let (sut, store) = makeSUT()
        
        store.completeRecordsRetrievalWithEmptyStore()
        let records = try sut.load()
        
        XCTAssertEqual(records, [])
    }
    
    func test_load_returnsRecordCountOnNonEmptyStore() throws {
        let (sut, store) = makeSUT()
        let records = [anyPlayerRecord()]
        
        store.completeRecordsRetrieval(with: records)
        let retrievedRecords = try sut.load()
        
        XCTAssertEqual(retrievedRecords, records)
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

