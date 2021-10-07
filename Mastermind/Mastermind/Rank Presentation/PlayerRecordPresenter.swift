//
//  PlayerRecordPresenter.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/10/7.
//

import Foundation

public final class PlayerRecordPresenter {
    private let formatter: DateComponentsFormatter
    private let record: PlayerRecord?
    
    public init(formatter: DateComponentsFormatter, record: PlayerRecord?) {
        self.formatter = formatter
        self.record = record
    }
    
    public var viewModel: RecordViewModel {
        let playerName = record?.playerName ?? "-----"
        let guessCount = record?.guessCount.description ?? "--"
        var guessTimeString = "--:--:--"
        if let guessTime = record?.guessTime, let formattedString =  formatter.string(from: guessTime) {
            guessTimeString = formattedString
        }
        
        return RecordViewModel(playerName: playerName, guessCount: guessCount, guessTime: guessTimeString)
    }
}
