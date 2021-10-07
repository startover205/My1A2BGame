//
//  RecordViewModel.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/10/7.
//

public struct RecordViewModel {
    public let playerName: String
    public let guessCount: String
    public let guessTime: String
    
    public init(playerName: String, guessCount: String, guessTime: String) {
        self.playerName = playerName
        self.guessCount = guessCount
        self.guessTime = guessTime
    }
}
