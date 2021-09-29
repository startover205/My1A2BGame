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

public protocol RecordSaveView {
    func display(_ viewModel: RecordSaveResultAlertViewModel)
}

public struct RecordSaveResultAlertViewModel {
    public let success: Bool
    public let title: String
    public let message: String?
    public let confirmTitle: String
}

public final class RecordPresenter {
    private let validationView: RecordValidationView
    private let saveView: RecordSaveView
    
    internal init(validationView: RecordValidationView, saveView: RecordSaveView) {
        self.validationView = validationView
        self.saveView = saveView
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
    
    public func didSaveRecord(with error: Error) {
        saveView.display(RecordSaveResultAlertViewModel(success: false, title: Self.saveFailureAlertTitle, message: error.localizedDescription, confirmTitle: Self.saveResultAlertConfirmTitle))
    }
    
    public func didSaveRecordSuccessfully() {
        saveView.display(RecordSaveResultAlertViewModel(success: true, title: Self.saveSuccessAlertTitle, message: nil, confirmTitle: Self.saveResultAlertConfirmTitle))
    }
}


class RecordPresenterTests: XCTestCase {
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
    
    func test_didSaveRecordWithError_displaysErrorAlert() {
        let (sut, view) = makeSUT()
        let saveError = anyNSError()
        
        sut.didSaveRecord(with: saveError)
        
        XCTAssertEqual(view.receivedMessages, [.display(
                                                saveSuccess: false,
                                                alertTitle: localized("SAVE_FAILURE_ALERT_TITLE"),
                                                alertMessage: saveError.localizedDescription,
                                                alertConfirmTitle: localized("SAVE_RESULT_ALERT_CONFIRM_TITLE"))])
    }
    
    func test_didSaveRecordSuccesfully_displaysSuccessAlert() {
        let (sut, view) = makeSUT()
        
        sut.didSaveRecordSuccessfully()
        
        XCTAssertEqual(view.receivedMessages, [.display(
                                                saveSuccess: true,
                                                alertTitle: localized("SAVE_SUCCESS_ALERT_TITLE"),
                                                alertMessage: nil,
                                                alertConfirmTitle: localized("SAVE_RESULT_ALERT_CONFIRM_TITLE"))])
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RecordPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = RecordPresenter(validationView: view, saveView: view)
        
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, view)
    }
    
    private final class ViewSpy: RecordValidationView, RecordSaveView {
        enum Message: Hashable {
            case display(isValidRecord: Bool)
            case display(saveSuccess: Bool, alertTitle: String, alertMessage: String?, alertConfirmTitle: String)
        }
        
        private(set) var receivedMessages = Set<Message>()
        
        func display(_ viewModel: RecordValidationViewModel) {
            receivedMessages.insert(.display(isValidRecord: viewModel.isValid))
        }
        
        func display(_ viewModel: RecordSaveResultAlertViewModel) {
            receivedMessages.insert(.display(saveSuccess: viewModel.success, alertTitle: viewModel.title, alertMessage: viewModel.message, alertConfirmTitle: viewModel.confirmTitle))
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
