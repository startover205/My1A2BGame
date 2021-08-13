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
    
    public func loadCount() throws -> Int {
        try store.totalCount()
    }
    
    public func loadRecords() throws -> [PlayerRecord] {
        try store.retrieve()
    }
}

extension RecordLoader {
    public func validateNewRecord(with newRecord: PlayerRecord) -> Bool {
        do {
            let records = try store.retrieve()
            
            if records.count < 10 { return true }
            
            for oldRecord in records {
                if  newRecord.guessCount < oldRecord.guessCount {
                    return true
                } else if newRecord.guessCount == newRecord.guessCount, newRecord.guessTime < oldRecord.guessTime {
                    return true
                }
            }
            
            return false
            
        } catch {
            return false
        }
    }
}

extension RecordLoader {
    public func insertNewRecord(_ record: PlayerRecord) throws {
        
    }
}
