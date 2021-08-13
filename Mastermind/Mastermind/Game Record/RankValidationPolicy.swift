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
    
    static func validate(_ newRecord: PlayerRecord, against oldRecords: [PlayerRecord]) -> Bool {
        
        if oldRecords.count < maxRankPositions { return true }
        
        for oldRecord in oldRecords {
            if  newRecord.guessCount < oldRecord.guessCount {
                return true
            } else if newRecord.guessCount == newRecord.guessCount, newRecord.guessTime < oldRecord.guessTime {
                return true
            }
        }
        
        return false
    }
}

