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
        case retrieve
        case insert(_ record: LocalPlayerRecord)
        case delete(_ record: [LocalPlayerRecord])
    }
    
    private(set) var receivedMessages = [Message]()
    private var retrievalRecordsError: Error?
    private var insertionResult: Result<Void, Error>?
    private var deletionResult: Result<Void, Error>?
    private var records = [LocalPlayerRecord]()
    
    func retrieve() throws -> [LocalPlayerRecord] {
        receivedMessages.append(.retrieve)
        if let error = retrievalRecordsError {
            throw error
        } else {
            return records
        }
    }
    
    func insert(_ record: LocalPlayerRecord) throws {
        receivedMessages.append(.insert(record))
        try insertionResult?.get()
    }
    
    func delete(_ records: [LocalPlayerRecord]) throws {
        receivedMessages.append(.delete(records))
        try deletionResult?.get()
    }
    
    func completeRecordsRetrieval(with error: Error) {
        retrievalRecordsError = error
    }
    
    func completeRecordsRetrieval(with records: [LocalPlayerRecord]) {
        self.records = records
    }
    
    func completeRecordsRetrievalWithEmptyStore() {
        records = []
    }
    
    func completeInsertion(with error: Error) {
        insertionResult = .failure(error)
    }
    
    func completeInsertionSuccessfully() {
        insertionResult = .success(())
    }
    
    func completeDeletion(with error: Error) {
        deletionResult = .failure(error)
    }
}
