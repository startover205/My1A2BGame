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
        let sut = CoreDataRecordStore()
        
        let result = try? sut.retrieve()
        
        XCTAssertEqual(result, [])
    }
    
    func test_retrieve_hasNoSideEffectsOnRetrieval() {
        let sut = CoreDataRecordStore()
        
        let firstResult = try? sut.retrieve()
        XCTAssertEqual(firstResult, [])

        let secondResult = try? sut.retrieve()
        XCTAssertEqual(secondResult, [])
    }
}
