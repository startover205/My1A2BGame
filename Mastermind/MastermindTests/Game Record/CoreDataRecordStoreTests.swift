//
//  CoreDataRecordStoreTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/14.
//

import XCTest
import Mastermind

final class CoreDataRecordStore: RecordStore {
    func totalCount() throws -> Int {
        return 0
    }
    
    func retrieve() throws -> [PlayerRecord] {
        return []
    }
    
    func insert(_ record: PlayerRecord) throws {
    }
    
    func delete(_ records: [PlayerRecord]) throws {
    }
}

class CoreDataRecordStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyStore() {
        let sut = CoreDataRecordStore()
        
        let result = try? sut.retrieve()
        
        XCTAssertEqual(result, [])
    }

}
