//
//  RecordStore.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/13.
//

import Foundation

public protocol RecordStore {
    func totalCount() throws -> Int
    
    func retrieve() throws -> [PlayerRecord]
}