//
//  NumberInputPresenterTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/10/4.
//

import XCTest
import Mastermind

class NumberInputPresenterTests: XCTestCase {

    func test_viewModel_providesLocalizedText() {
        XCTAssertEqual(NumberInputPresenter.viewModel.viewTitle, localized("VIEW_TITLE"))
        XCTAssertEqual(NumberInputPresenter.viewModel.clearInputAction, localized("CLEAR_INPUT_ACTION"))
    }
    
    // MARK: - Helpers

    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "NumberInput"
        let bundle = Bundle(for: NumberInputPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
