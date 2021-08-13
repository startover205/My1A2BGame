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
    
    public func validateNewRecord(with: PlayerRecord) -> Bool {
        do {
            let _ = try store.retrieve()
            return true
        } catch {
            return false
        }
    }
}
