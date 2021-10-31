//
//  CoreDataRecordStoreTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/14.
//

import XCTest
import Mastermind

class CoreDataRecordStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyStore() throws {
        let sut = makeSUT()
        
        let result = try sut.retrieve()
        
        XCTAssertEqual(result, [])
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyStore() throws {
        let sut = makeSUT()
        
        let firstResult = try sut.retrieve()
        XCTAssertEqual(firstResult, [])

        let secondResult = try sut.retrieve()
        XCTAssertEqual(secondResult, [])
    }
    
    func test_retrieve_deliversFoundValueOrderedByGuessCountAndGuessTimeOnNonEmptyStore() throws {
        let sut = makeSUT()
        let recordWithLowestGuessCount = LocalPlayerRecord(playerName: "a name", guessCount: 1, guessTime: 600.0, timestamp: Date())
        let recordWithModerateGuessCountAndLowestGuessTime = LocalPlayerRecord(playerName: "another name", guessCount: 3, guessTime: 30.0, timestamp: Date())
        let recordWithModerateGuessCountAndLongesGuessTime = LocalPlayerRecord(playerName: "and another name", guessCount: 3, guessTime: 30.1, timestamp: Date())

        try sut.insert(recordWithModerateGuessCountAndLowestGuessTime)
        try sut.insert(recordWithLowestGuessCount)
        try sut.insert(recordWithModerateGuessCountAndLongesGuessTime)
        
        let result = try sut.retrieve()
        XCTAssertEqual(result, [recordWithLowestGuessCount, recordWithModerateGuessCountAndLowestGuessTime, recordWithModerateGuessCountAndLongesGuessTime])
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyStore() throws {
        let sut = makeSUT()
        let record = anyPlayerRecord().local
        
        try sut.insert(record)
        
        let firstResult = try sut.retrieve()
        XCTAssertEqual(firstResult, [record])

        let secondResult = try sut.retrieve()
        XCTAssertEqual(secondResult, [record])
    }
    
    func test_retrieve_deliverFailureOnRetrievalError() {
        let stub = NSManagedObjectContext.alwaysFailingFetchStub()
        stub.startIntercepting()
        
        let sut = makeSUT()
        
        XCTAssertThrowsError(try sut.retrieve())
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let stub = NSManagedObjectContext.alwaysFailingFetchStub()
        stub.startIntercepting()
        
        let sut = makeSUT()
        
        XCTAssertThrowsError(try sut.retrieve())
        XCTAssertThrowsError(try sut.retrieve())
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let record = anyPlayerRecord().local
        
        XCTAssertNoThrow(try sut.insert(record))
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let record = anyPlayerRecord().local
        
        try! sut.insert(record)
        
        XCTAssertNoThrow(try sut.insert(record))
    }
    
    func test_insert_deliverFailureOnInsertionError() {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        stub.startIntercepting()
        let record = anyPlayerRecord().local
        
        let sut = makeSUT()
        
        XCTAssertThrowsError(try sut.insert(record))
    }
    
    func test_insert_hasNoSideEffectsOnFailure() {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        stub.startIntercepting()
        let record = anyPlayerRecord().local
        
        let sut = makeSUT()
        try? sut.insert(record)
        
        XCTAssertEqual(try sut.retrieve(), [])
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let records = anyPlayerRecords().local
        
        XCTAssertNoThrow(try sut.delete(records))
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let records = anyPlayerRecords().local
        
        try! sut.delete(records)
        
        XCTAssertEqual(try sut.retrieve(), [])
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let existingRecord = anyPlayerRecord().local
        
        try! sut.insert(existingRecord)
        
        XCTAssertNoThrow(try sut.delete([existingRecord]))
    }
    
    func test_delete_deliversDeleteRecordsWithMatchingTimestamp() {
        let sut = makeSUT()
        let firstRecord = LocalPlayerRecord(playerName: "same name", guessCount: 1, guessTime: 1, timestamp: Date())
        let secondRecord = LocalPlayerRecord(playerName: "same name", guessCount: 1, guessTime: 1, timestamp: Date().addingTimeInterval(1))
        let thirdRecord = LocalPlayerRecord(playerName: "same name", guessCount: 1, guessTime: 1, timestamp: Date().addingTimeInterval(2))
        
        try! sut.insert(firstRecord)
        try! sut.insert(secondRecord)
        try! sut.insert(thirdRecord)
        
        try! sut.delete([firstRecord, thirdRecord])
        
        let result = try! sut.retrieve()
        
        XCTAssertEqual(result, [secondRecord])
    }
    
    func test_delete_deliverFailureOnDeletionError() {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        let sut = makeSUT()
        let record = anyPlayerRecord().local
        
        try! sut.insert(record)
        
        stub.startIntercepting()
        
        XCTAssertThrowsError(try sut.delete([record]))
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        let sut = makeSUT()
        let record = anyPlayerRecord().local
        
        try! sut.insert(record)
        
        stub.startIntercepting()
        
        try? sut.delete([record])
        
        XCTAssertEqual(try sut.retrieve(), [record])
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> RecordStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let modelName = "Model"
        let sut = try! CoreDataRecordStore<Winner>(storeURL: storeURL, modelName: modelName)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
