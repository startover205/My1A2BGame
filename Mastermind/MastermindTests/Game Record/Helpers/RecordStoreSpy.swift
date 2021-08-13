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
    }
    
    private(set) var receivedMessages = [Message]()
    private var retrievalCountResult: Result<Int, Error>?
    private var retrievalRecordsResult: Result<[PlayerRecord], Error>?
    
    func totalCount() throws -> Int {
        receivedMessages.append(.loadCount)
        return try retrievalCountResult?.get() ?? 0
    }
    
    func retrieve() throws -> [PlayerRecord] {
        receivedMessages.append(.loadRecords)
        return try retrievalRecordsResult?.get() ?? []
    }
    
    func completeCountRetrieval(with error: Error) {
        retrievalCountResult = .failure(error)
    }
    
    func completeCountRetrieval(with count: Int) {
        retrievalCountResult = .success(count)
    }
    
    func completeCountRetrievalWithEmptyStore() {
        retrievalCountResult = .success(0)
    }
    
    func completeRecordsRetrieval(with error: Error) {
        retrievalRecordsResult = .failure(error)
    }
    
    func completeRecordsRetrieval(with records: [PlayerRecord]) {
        retrievalRecordsResult = .success(records)
    }
    
    func completeRecordsRetrievalWithEmptyStore() {
        retrievalRecordsResult = .success([])
    }
}
