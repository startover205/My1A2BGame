//
//  RecordLoader.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/13.
//

import Foundation

public final class LocalRecordLoader: RecordLoader {
    private let store: RecordStore
    
    public init(store: RecordStore) {
        self.store = store
    }
    
    public func load() throws -> [PlayerRecord] {
        try store.retrieve().toModels()
    }
}

extension LocalRecordLoader {
    public func validate(score: Score) -> Bool {
        do {
            let oldRecords = try store.retrieve()
            
            return RankValidationPolicy.validate(score, against: oldRecords)
            
        } catch {
            return false
        }
    }
}

extension LocalRecordLoader {
    public func insertNewRecord(_ record: PlayerRecord) throws {
        let oldRecords = try store.retrieve()
        if !RankValidationPolicy.validate(record.score, against: oldRecords) { return }
        
        if let recordsToBeDeleted = RankValidationPolicy.findInvalidRecords(in: oldRecords) {
            try store.delete(recordsToBeDeleted)
        }
        
        try store.insert(record.toLocal())
    }
}

private extension PlayerRecord {
    var score: Score { (guessCount, guessTime) }
    
    func toLocal() -> LocalPlayerRecord {
        LocalPlayerRecord(playerName: playerName, guessCount: guessCount, guessTime: guessTime, timestamp: timestamp)
    }
}

private extension Array where Element == LocalPlayerRecord {
    func toModels() -> [PlayerRecord] {
        map { PlayerRecord(playerName: $0.playerName, guessCount: $0.guessCount, guessTime: $0.guessTime, timestamp: $0.timestamp) }
    }
}
