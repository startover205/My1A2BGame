//
//  InMemoryRecordLoader.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/12/8.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import Mastermind

class InMemoryRecordLoader: RecordLoader {
    private var records = [PlayerRecord]()
    
    func load() throws -> [PlayerRecord] { records }
    
    func validate(score: Score) -> Bool {
        for record in records {
            if  score.guessCount < record.guessCount {
                return true
            } else if score.guessCount == record.guessCount, score.guessTime < record.guessTime {
                return true
            }
        }
        return false
    }
    
    func insertNewRecord(_ record: PlayerRecord) throws {
        records.append(record)
    }
}
