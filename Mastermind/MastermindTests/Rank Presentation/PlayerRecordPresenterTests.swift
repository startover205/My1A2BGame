//
//  PlayerRecordPresenterTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/10/7.
//

import XCTest
import Mastermind

public struct RecordViewModel {
    public init(playerName: String, guessCount: String, guessTime: String) {
        self.playerName = playerName
        self.guessCount = guessCount
        self.guessTime = guessTime
    }
    
    public let playerName: String
    public let guessCount: String
    public let guessTime: String
}


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

class PlayerRecordPresenterTests: XCTestCase {
    
    func test_NonNilRecord_providesViewModelWithValidData() {
        let formatter = guessTimeFormatter()
        let record = PlayerRecord(playerName: "a name", guessCount: 14, guessTime: 520, timestamp: Date())
        let sut = PlayerRecordPresenter(formatter: formatter, record: record)
        
        XCTAssertEqual(sut.viewModel.playerName, "a name")
        XCTAssertEqual(sut.viewModel.guessCount, "14")
        XCTAssertEqual(sut.viewModel.guessTime, "00:08:40")
    }
    
    func test_NilRecord_providesPlacehodlerViewModel() {
        let anyFormatter = DateComponentsFormatter()
        let sut = PlayerRecordPresenter(formatter: anyFormatter, record: nil)
        
        XCTAssertEqual(sut.viewModel.playerName, "-----")
        XCTAssertEqual(sut.viewModel.guessCount, "--")
        XCTAssertEqual(sut.viewModel.guessTime, "--:--:--")
    }
    
    // MARK: - Helpers
    
    private func guessTimeFormatter() -> DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }

}
