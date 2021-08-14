//
//  RecordStoreTestHelpers.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/13.
//

import Mastermind

func anyPlayerRecord() -> PlayerRecord {
    PlayerRecord(playerName: "a name", guessCount: 10, guessTime: 10)
}

func oneWorstRecord() -> PlayerRecord {
    .init(playerName: "a name", guessCount: 100, guessTime: 1000)
}

func recordsWithOneWorstRecord() -> (all: [PlayerRecord], theWorst: PlayerRecord) {
    var records = Array(repeating: anyPlayerRecord(), count: 9)
    let worstRecord = oneWorstRecord()
    records.append(worstRecord)
    return (records, worstRecord)
}

func oneOfTheBestRecord() -> PlayerRecord {
    .init(playerName: "a name", guessCount: 1, guessTime: 1)
}
