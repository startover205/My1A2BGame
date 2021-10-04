//
//  NumberInputPresenterTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/10/4.
//

import XCTest

public struct NumberInputViewModel {
    let viewTitle: String
    let cancelInputAction: String
    let clearInputAction: String
}

public final class NumberInputPresenter {
    private init() {}
    
    private static var viewTitle: String {
        NSLocalizedString("VIEW_TITLE",
                          tableName: "NumberInput",
                          bundle: Bundle(for: NumberInputPresenter.self),
                          comment: "Title for number input view")
    }
    
    private static var cancelInputAction: String {
        NSLocalizedString("DISMISS_VIEW_ACTION",
                          tableName: "NumberInput",
                          bundle: Bundle(for: NumberInputPresenter.self),
                          comment: "Button for canceling number input")
    }
    
    private static var clearInputAction: String {
        NSLocalizedString("CLEAR_INPUT_ACTION",
                          tableName: "NumberInput",
                          bundle: Bundle(for: NumberInputPresenter.self),
                          comment: "Button for clearing current inputs")
    }
    
    public static var viewModel: NumberInputViewModel {
        .init(viewTitle: Self.viewTitle,
              cancelInputAction: Self.cancelInputAction,
              clearInputAction: Self.clearInputAction)
    }
    
}

class NumberInputPresenterTests: XCTestCase {

    func test_viewModel_providesLocalizedText() {
        XCTAssertEqual(NumberInputPresenter.viewModel.viewTitle, localized("VIEW_TITLE"))
        XCTAssertEqual(NumberInputPresenter.viewModel.cancelInputAction, localized("DISMISS_VIEW_ACTION"))
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
