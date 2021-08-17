//
//  RecordLoader.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/17.
//

import Foundation

public typealias Score = (guessCount: Int, guessTime: TimeInterval)

public protocol RecordLoader {
    func load() throws -> [PlayerRecord]
    
    func validate(score: Score) -> Bool
    
    func insertNewRecord(_ record: PlayerRecord) throws
}
