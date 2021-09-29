//
//  RecordPresenterTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/9/29.
//

import XCTest

public protocol RecordValidationView {
    func display(_ viewModel: RecordValidationViewModel)
}

public struct RecordValidationViewModel {
    public let isValid: Bool
}

public final class RecordPresenter {
    private let validationView: RecordValidationView
    
    internal init(validationView: RecordValidationView) {
        self.validationView = validationView
    }
    
    static var saveSuccessAlertTitle: String {
        NSLocalizedString("SAVE_SUCCESS_ALERT_TITLE",
                          tableName: "Record",
                          bundle: Bundle(for: RecordPresenter.self),
                          comment: "Title for save success alert")
    }
    
    static var saveFailureAlertTitle: String {
        NSLocalizedString("SAVE_FAILURE_ALERT_TITLE",
                          tableName: "Record",
                          bundle: Bundle(for: RecordPresenter.self),
                          comment: "Title for save failure alert")
    }
    
    static var saveResultAlertConfirmTitle: String {
        NSLocalizedString("SAVE_RESULT_ALERT_CONFIRM_TITLE",
                          tableName: "Record",
                          bundle: Bundle(for: RecordPresenter.self),
                          comment: "Confirm title for save failure alert")
    }
    
    public func didValidateRecord(_ isValid: Bool) {
        validationView.display(RecordValidationViewModel(isValid: isValid))
    }
}


class RecordPresenterTests: XCTestCase {
    func test_saveSuccessAlertTitle_isLocalized() {
        XCTAssertEqual(RecordPresenter.saveSuccessAlertTitle, localized("SAVE_SUCCESS_ALERT_TITLE"))
    }
    
    func test_saveFailureAlertTitle_isLocalized() {
        XCTAssertEqual(RecordPresenter.saveFailureAlertTitle, localized("SAVE_FAILURE_ALERT_TITLE"))
    }
    
    func test_saveResultAlertConfirmTitle_isLocalized() {
        XCTAssertEqual(RecordPresenter.saveResultAlertConfirmTitle, localized("SAVE_RESULT_ALERT_CONFIRM_TITLE"))
    }
    
    func test_init_doesNotMessageView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.receivedMessages.isEmpty)
    }
    
    func test_didValidateRecord_displaysValidationResult() {
        let (sut, view) = makeSUT()
        
        sut.didValidateRecord(true)
        XCTAssertEqual(view.receivedMessages, [.display(isValidRecord: true)])
        
        sut.didValidateRecord(false)
        XCTAssertEqual(view.receivedMessages, [
                        .display(isValidRecord: true),
                        .display(isValidRecord: false)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RecordPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = RecordPresenter(validationView: view)
        
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, view)
    }
    
    private final class ViewSpy: RecordValidationView {
        enum Message: Hashable {
            case display(isValidRecord: Bool)
        }
        
        private(set) var receivedMessages = Set<Message>()
        
        func display(_ viewModel: RecordValidationViewModel) {
            receivedMessages.insert(.display(isValidRecord: viewModel.isValid))
        }
    }
    
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Record"
        let bundle = Bundle(for: RecordPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
