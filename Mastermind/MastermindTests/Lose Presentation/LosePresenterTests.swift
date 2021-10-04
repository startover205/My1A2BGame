//
//  LosePresenterTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/10/3.
//

import XCTest
import Mastermind

class LosePresenterTests: XCTestCase {
    
    func test_loseViewModel_providesLoseMessageAndEncouragementMessage() {
        let viewModel = LosePresenter.loseViewModel
        
        XCTAssertEqual(viewModel.loseMessage, localized("LOSE_MESSAGE"))
        XCTAssertEqual(viewModel.encouragementMessage, localized("ENCOURAGEMENT_MESSAGE"))
    }
    
    // MARK: - Helpers

    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Lose"
        let bundle = Bundle(for: LosePresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
