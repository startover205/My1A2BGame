//
//  RecordPresenter.swift
//  MastermindiOS
//
//  Created by Ming-Ta Yang on 2021/9/8.
//

import Foundation

public final class RecordPresenter {
    private let recordSaveView: RecordSaveView
    private let recordValidationView: RecordValidationView
    
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
        NSLocalizedString("SAVE_RECORD_ALERT_CONFIRM_TITLE",
                          tableName: "Record",
                          bundle: Bundle(for: RecordPresenter.self),
                          comment: "Confirm title for save failure alert")
    }
    
    public init(recordSaveView: RecordSaveView, recordValidationView: RecordValidationView) {
        self.recordSaveView = recordSaveView
        self.recordValidationView = recordValidationView
    }
    
    public func didValidateRecord(_ isValid: Bool) {
        recordValidationView.display(RecordValidationViewModel(isValid: isValid))
    }
    
    public func didSaveRecordSuccessfully() {
        recordSaveView.display(RecordSaveResultViewModel(success: true, title: Self.saveSuccessAlertTitle, message: nil, confirmTitle: Self.saveResultAlertConfirmTitle))
    }
    
    public func didSaveRecord(with error: Error) {
        recordSaveView.display(RecordSaveResultViewModel(success: false, title: Self.saveFailureAlertTitle, message: error.localizedDescription, confirmTitle: Self.saveResultAlertConfirmTitle))
    }
}
