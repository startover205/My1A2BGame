//
//  LocalPlayerRecord.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/16.
//

import Foundation

public struct LocalPlayerRecord: Equatable {
    public let playerName: String
    public let guessCount: Int
    public let guessTime: TimeInterval
    public let timestamp: Date
    
    public init(playerName: String, guessCount: Int, guessTime: TimeInterval, timestamp: Date) {
        self.playerName = playerName
        self.guessCount = guessCount
        self.guessTime = guessTime
        self.timestamp = timestamp
    }
}
