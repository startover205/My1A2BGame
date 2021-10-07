//
//  PlayerRecordPresenterTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/10/7.
//

import XCTest
import Mastermind

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
