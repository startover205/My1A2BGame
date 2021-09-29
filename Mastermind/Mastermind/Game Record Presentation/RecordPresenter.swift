//
//  RecordPresenter.swift
//  MastermindiOS
//
//  Created by Ming-Ta Yang on 2021/9/8.
//

import Foundation

public final class RecordPresenter {
    private let validationView: RecordValidationView
    private let saveView: RecordSaveView
    
    public init(validationView: RecordValidationView, saveView: RecordSaveView) {
        self.validationView = validationView
        self.saveView = saveView
    }
    
    public static var saveSuccessAlertTitle: String {
        NSLocalizedString("SAVE_SUCCESS_ALERT_TITLE",
                          tableName: "Record",
                          bundle: Bundle(for: RecordPresenter.self),
                          comment: "Title for save success alert")
    }
    
    public static var saveFailureAlertTitle: String {
        NSLocalizedString("SAVE_FAILURE_ALERT_TITLE",
                          tableName: "Record",
                          bundle: Bundle(for: RecordPresenter.self),
                          comment: "Title for save failure alert")
    }
    
    public static var saveResultAlertConfirmTitle: String {
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
