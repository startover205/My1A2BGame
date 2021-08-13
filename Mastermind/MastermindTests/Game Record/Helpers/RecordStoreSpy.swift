//
//  RecordStoreSpy.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/13.
//

import Foundation
import Mastermind

final class RecordStoreSpy: RecordStore {
    enum Message: Equatable {
        case loadCount
        case loadRecords
        case insert(_ record: PlayerRecord)
    }
    
    private(set) var receivedMessages = [Message]()
    private var retrievalCountError: Error?
    private var retrievalRecordsError: Error?
    private var insertionResult: Result<Void, Error>?
    private var records = [PlayerRecord]()
    
    func totalCount() throws -> Int {
        receivedMessages.append(.loadCount)
        if let error = retrievalCountError {
            throw error
        } else {
            return records.count
        }
    }
    
    func retrieve() throws -> [PlayerRecord] {
        receivedMessages.append(.loadRecords)
        if let error = retrievalRecordsError {
            throw error
        } else {
            return records
        }
    }
    
    func insert(_ record: PlayerRecord) throws {
        receivedMessages.append(.insert(record))
        try insertionResult?.get()
    }
    
    func completeCountRetrieval(with error: Error) {
        retrievalCountError = error
    }
    
    func completeCountRetrieval(with count: Int) {
        records = Array(repeating: anyPlayerRecord(), count: count)
    }
    
    func completeCountRetrievalWithEmptyStore() {
        records = []
    }
    
    func completeRecordsRetrieval(with error: Error) {
        retrievalRecordsError = error
    }
    
    func completeRecordsRetrieval(with records: [PlayerRecord]) {
        self.records = records
    }
    
    func completeRecordsRetrievalWithEmptyStore() {
        records = []
    }
    
    func completeInsertion(with error: Error) {
        insertionResult = .failure(error)
    }
}
