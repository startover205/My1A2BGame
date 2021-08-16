//
//  RecordStoreTestHelpers.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/13.
//

import Foundation
import Mastermind

func anyPlayerRecord() -> (model: PlayerRecord, local: LocalPlayerRecord) {
    let model = PlayerRecord(playerName: "a name", guessCount: 10, guessTime: 10, timestamp: Date())
    return (model, model.local)
}

func anyPlayerRecords() -> (model: [PlayerRecord], local: [LocalPlayerRecord]) {
    let model = [anyPlayerRecord().model, anyPlayerRecord().model]
    let local = model.map { $0.local }
    return (model, local)
}

func oneWorstRecord() -> (model: PlayerRecord, local: LocalPlayerRecord) {
    let model = PlayerRecord(playerName: "a name", guessCount: 100, guessTime: 1000, timestamp: Date())
    return (model, model.local)
}

func recordsWithOneWorstRecord() -> (all: [LocalPlayerRecord], theWorst: LocalPlayerRecord) {
    var records = Array(repeating: anyPlayerRecord().local, count: 9)
    let worstRecord = oneWorstRecord().local
    records.append(worstRecord)
    return (records, worstRecord)
}

func oneOfTheBestRecord() -> (model: PlayerRecord, local: LocalPlayerRecord) {
    let model = PlayerRecord(playerName: "a name", guessCount: 1, guessTime: 1, timestamp: Date())
    return (model, model.local)
}

extension PlayerRecord {
    var local: LocalPlayerRecord {
        .init(playerName: playerName, guessCount: guessCount, guessTime: guessTime, timestamp: timestamp)
    }
}
