//
//  RecordLoaderTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/13.
//

import XCTest

protocol RecordStore {
    
}

class RecordLoader {
    let store: RecordStore
    
    init(store: RecordStore) {
        self.store = store
    }
}

class RecordLoaderTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
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
            
        }
        
        private(set) var receivedMessages = [Message]()
    }
}

