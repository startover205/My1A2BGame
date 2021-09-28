//
//  GameInstructionPresenterTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/9/28.
//

import XCTest
import Mastermind

class GameInstructionPresenterTests: XCTestCase {
    func test_instruction_isLocalized() {
        XCTAssertEqual(GameInstructionPresenter.instruction, localized("INSTRUCTION"))
    }

    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Game"
        let bundle = Bundle(for: GameInstructionPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
