//
//  RecordLoaderTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/13.
//

import XCTest

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
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RecordLoader, RecordStoreSpy) {
        let store = RecordStoreSpy()
        let sut = RecordLoader(store: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private final class RecordStoreSpy: RecordStore {
        enum Message: Equatable {
            case loadCount
        }
        
        private(set) var receivedMessages = [Message]()
        
        func totalCount() -> Int {
            receivedMessages.append(.loadCount)
            return 0
        }
    }
}

