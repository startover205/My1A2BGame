//
//  RecordViewModel.swift
//  MastermindiOS
//
//  Created by Ming-Ta Yang on 2021/8/23.
//

import Foundation
import Mastermind

public final class RecordViewModel {
    typealias Observer<T> = (T) -> Void
    
    public init(loader: RecordLoader, guessCount: @escaping (() -> Int), guessTime: @escaping (() -> TimeInterval), currentDate: @escaping (() -> Date)) {
        self.loader = loader
        self.guessCount = guessCount
        self.guessTime = guessTime
        self.currentDate = currentDate
    }
    
    private let loader: RecordLoader
    private let guessCount: (() -> Int)
    private let guessTime: (() -> TimeInterval)
    private let currentDate: (() -> Date)
    
    var onSave: Observer<Error?>?
    var onValidation: Observer<Bool>?
    
    func validateRecord() {
        onValidation?(loader.validate(score: (guessCount(), guessTime())))
    }
    
    func insertRecord(playerName: String) {
        let record = PlayerRecord(playerName: playerName, guessCount: guessCount(), guessTime: guessTime(), timestamp: currentDate())
        
        do {
            try loader.insertNewRecord(record)
            onSave?(nil)
        } catch {
            onSave?(error)
        }
    }
}
