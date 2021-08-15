//
//  CoreDataRecordStoreTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/14.
//

import XCTest
import Mastermind

class CoreDataRecordStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyStore() {
        let sut = makeSUT()
        
        let result = try? sut.retrieve()
        
        XCTAssertEqual(result, [])
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyStore() {
        let sut = makeSUT()
        
        let firstResult = try? sut.retrieve()
        XCTAssertEqual(firstResult, [])

        let secondResult = try? sut.retrieve()
        XCTAssertEqual(secondResult, [])
    }
    
    func test_retrieve_deliversFoundValueOnNonEmptyStore() {
        let sut = makeSUT()
        let record = anyPlayerRecord()
        
        try? sut.insert(record)
        
        let result = try? sut.retrieve()
        XCTAssertEqual(result, [record])
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyStore() {
        let sut = makeSUT()
        let record = anyPlayerRecord()
        
        try? sut.insert(record)
        
        let firstResult = try? sut.retrieve()
        XCTAssertEqual(firstResult, [record])

        let secondResult = try? sut.retrieve()
        XCTAssertEqual(secondResult, [record])
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let record = anyPlayerRecord()
        
        XCTAssertNoThrow(try sut.insert(record))
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let record = anyPlayerRecord()
        
        try! sut.insert(record)
        
        XCTAssertNoThrow(try sut.insert(record))
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataRecordStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let modelName = "Model"
        let sut = try! CoreDataRecordStore(storeURL: storeURL, modelName: modelName)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
