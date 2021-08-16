//
//  RecordStore.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/13.
//

import Foundation

public protocol RecordStore {
    func retrieve() throws -> [LocalPlayerRecord]
    
    func insert(_ record: LocalPlayerRecord) throws
    
    func delete(_ records: [LocalPlayerRecord]) throws
}
