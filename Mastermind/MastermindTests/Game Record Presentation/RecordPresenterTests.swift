//
//  RecordPresenterTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/9/29.
//

import XCTest
import Mastermind

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
