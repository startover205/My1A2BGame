//
//  CoreDataRecordStore.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/15.
//

import CoreData

public final class CoreDataRecordStore: RecordStore {
    public init() {}
    
    public func totalCount() throws -> Int {
        return 0
    }
    
    public func retrieve() throws -> [PlayerRecord] {
        return []
    }
    
    public func insert(_ record: PlayerRecord) throws {
    }
    
    public func delete(_ records: [PlayerRecord]) throws {
    }
}
