//
//  RecordLoader.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/13.
//

import Foundation

public final class RecordLoader {
    private let store: RecordStore
    
    public init(store: RecordStore) {
        self.store = store
    }
    
    public func load() throws -> [PlayerRecord] {
        try store.retrieve()
    }
}

extension RecordLoader {
    public func validateNewRecord(with newRecord: PlayerRecord) -> Bool {
        do {
            let oldRecords = try store.retrieve()
            
            return RankValidationPolicy.validate(newRecord, against: oldRecords)
            
        } catch {
            return false
        }
    }
}

extension RecordLoader {
    public func insertNewRecord(_ record: PlayerRecord) throws {
        let oldRecords = try store.retrieve()
        if !RankValidationPolicy.validate(record, against: oldRecords) { return }
        
        if let recordsToBeDeleted = RankValidationPolicy.findInvalidRecords(in: oldRecords) {
            try store.delete(recordsToBeDeleted)
        }
        
        try store.insert(record)
    }
}
