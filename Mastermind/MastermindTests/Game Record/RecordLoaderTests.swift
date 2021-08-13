//
//  RecordLoaderTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/13.
//

import XCTest

class PlayerRecord {
    
}

protocol RecordStore {
    func totalCount() throws -> Int
}

class RecordLoader {
    let store: RecordStore
    
    init(store: RecordStore) {
        self.store = store
    }
    
    func loadCount() throws -> Int {
        try store.totalCount()
    }
}

class RecordLoaderTests: XCTestCase {
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
        
        store.completeCountRetrievalWithError(retrievalError)
        
        XCTAssertThrowsError(try sut.loadCount())
    }
    
    func test_loadCount_returnsZeroOnEmptyStore() throws {
        let (sut, store) = makeSUT()
        
        store.completeCountRetrievalWithEmptyStore()
        let recordCount = try sut.loadCount()
        
        XCTAssertEqual(recordCount, 0)
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
        }
        
        private(set) var receivedMessages = [Message]()
        private var retrievalCountResult: Result<Int, Error>?
        func totalCount() throws -> Int {
            receivedMessages.append(.loadCount)
            return try retrievalCountResult?.get() ?? 0
        }
        
        func completeCountRetrievalWithError(_ error: Error) {
            retrievalCountResult = .failure(error)
        }
        
        func completeCountRetrievalWithEmptyStore() {
            retrievalCountResult = .success(0)
        }
    }
}

