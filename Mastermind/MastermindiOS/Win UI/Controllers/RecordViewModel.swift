//
//  RecordViewModel.swift
//  MastermindiOS
//
//  Created by Ming-Ta Yang on 2021/8/23.
//

import Foundation
import Mastermind

public final class RecordViewModel {
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
    
    var onChange: ((RecordViewModel) -> Void)?
    
    enum SaveState {
        case pending
        case saved
        case failed(Error)
    }
    
    private enum ValidationState {
        case pending
        case validated(Bool)
    }
    
    var saveState: SaveState = .pending {
        didSet { onChange?(self) }
    }
    
    private var validationState: ValidationState = .pending {
        didSet { onChange?(self) }
    }
    
    var breakRecord: Bool {
        switch validationState {
        case let .validated(valid): return valid
        case .pending: return false
        }
    }
    
    func validateRecord() {
        validationState = .validated(loader.validate(score: (guessCount(), guessTime())))
    }
    
    func insertRecord(playerName: String) {
        let record = PlayerRecord(playerName: playerName, guessCount: guessCount(), guessTime: guessTime(), timestamp: currentDate())
        
        do {
            try loader.insertNewRecord(record)
            saveState = .saved
        } catch {
            saveState = .failed(error)
        }
    }
}
