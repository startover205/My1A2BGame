//
//  RecordLoader.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/17.
//

import Foundation

public protocol RecordLoader {
    func load() throws -> [PlayerRecord]
    
    func validateNewRecord(with newRecord: PlayerRecord) -> Bool
    
    func insertNewRecord(_ record: PlayerRecord) throws
}
