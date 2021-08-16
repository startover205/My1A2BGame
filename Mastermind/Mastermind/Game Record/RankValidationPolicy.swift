//
//  RankValidationPolicy.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/13.
//

import Foundation

final class RankValidationPolicy {
    private init() {}
    
    private static var maxRankPositions: Int { 10 }
    
    static func validate(_ newRecord: LocalPlayerRecord, against oldRecords: [LocalPlayerRecord]) -> Bool {
        
        if oldRecords.count < maxRankPositions { return true }
        
        for oldRecord in oldRecords {
            if  newRecord.guessCount < oldRecord.guessCount {
                return true
            } else if newRecord.guessCount == oldRecord.guessCount, newRecord.guessTime < oldRecord.guessTime {
                return true
            }
        }
        
        return false
    }
    
    static func findInvalidRecords(in records: [LocalPlayerRecord]) -> [LocalPlayerRecord]? {
        if records.count < maxRankPositions { return nil }
        
        let sorted = records.sorted {
            ($0.guessCount, $0.guessTime) < ($1.guessCount, $1.guessTime)
        }
        
        return Array(sorted[maxRankPositions-1..<records.count])
    }
}

