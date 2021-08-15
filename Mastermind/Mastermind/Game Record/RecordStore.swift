//
//  RecordStore.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/13.
//

import Foundation

public protocol RecordStore {
    func retrieve() throws -> [PlayerRecord]
    
    func insert(_ record: PlayerRecord) throws
    
    func delete(_ records: [PlayerRecord]) throws
}
