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
    
    func test_loadCount_requestRecordCountRetrieval() throws {
        let (sut, store) = makeSUT()
        
        _ = try sut.loadCount()
        
        XCTAssertEqual(store.receivedMessages, [.loadCount])
    }
    
    func test_loadCount_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        store.completeCountRetrieval(with: retrievalError)
        
        XCTAssertThrowsError(try sut.loadCount())
    }
    
    func test_loadCount_returnsZeroOnEmptyStore() throws {
        let (sut, store) = makeSUT()
        
        store.completeCountRetrievalWithEmptyStore()
        let recordCount = try sut.loadCount()
        
        XCTAssertEqual(recordCount, 0)
    }
    
    func test_loadCount_returnsRecordCountOnNonEmptyStore() throws {
        let (sut, store) = makeSUT()
        let count = 10
        
        store.completeCountRetrieval(with: count)
        let recordCount = try sut.loadCount()
        
        XCTAssertEqual(recordCount, count)
    }
    
    func test_loadRecords_requestRecordsRetrieval() throws {
        let (sut, store) = makeSUT()
        
        _ = try sut.loadRecords()
        
        XCTAssertEqual(store.receivedMessages, [.loadRecords])
    }
    
    func test_loadRecords_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        store.completeRecordsRetrieval(with: retrievalError)
        
        XCTAssertThrowsError(try sut.loadRecords())
    }
    
    func test_loadRecords_returnsNoRecordsOnEmptyStore() throws {
        let (sut, store) = makeSUT()
        
        store.completeRecordsRetrievalWithEmptyStore()
        let records = try sut.loadRecords()
        
        XCTAssertEqual(records, [])
    }
    
    func test_loadRecords_returnsRecordCountOnNonEmptyStore() throws {
        let (sut, store) = makeSUT()
        let records = [PlayerRecord()]
        
        store.completeRecordsRetrieval(with: records)
        let retrievedRecords = try sut.loadRecords()
        
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
    
    private func anyNSError() -> NSError { NSError(domain: "any error", code: 0) }
    
    private final class RecordStoreSpy: RecordStore {
        enum Message: Equatable {
            case loadCount
            case loadRecords
        }
        
        private(set) var receivedMessages = [Message]()
        private var retrievalCountResult: Result<Int, Error>?
        private var retrievalRecordsResult: Result<[PlayerRecord], Error>?
        
        func totalCount() throws -> Int {
            receivedMessages.append(.loadCount)
            return try retrievalCountResult?.get() ?? 0
        }
        
        func retrieve() throws -> [PlayerRecord] {
            receivedMessages.append(.loadRecords)
            return try retrievalRecordsResult?.get() ?? []
        }
        
        func completeCountRetrieval(with error: Error) {
            retrievalCountResult = .failure(error)
        }
        
        func completeCountRetrieval(with count: Int) {
            retrievalCountResult = .success(count)
        }
        
        func completeCountRetrievalWithEmptyStore() {
            retrievalCountResult = .success(0)
        }
        
        func completeRecordsRetrieval(with error: Error) {
            retrievalRecordsResult = .failure(error)
        }
        
        func completeRecordsRetrieval(with records: [PlayerRecord]) {
            retrievalRecordsResult = .success(records)
        }
        
        func completeRecordsRetrievalWithEmptyStore() {
            retrievalRecordsResult = .success([])
        }
    }
}

