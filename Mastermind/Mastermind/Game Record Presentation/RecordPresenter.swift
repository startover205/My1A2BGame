//
//  RecordPresenter.swift
//  MastermindiOS
//
//  Created by Ming-Ta Yang on 2021/9/8.
//

public final class RecordPresenter {
    private let recordSaveView: RecordSaveView
    private let recordValidationView: RecordValidationView
    
    public init(recordSaveView: RecordSaveView, recordValidationView: RecordValidationView) {
        self.recordSaveView = recordSaveView
        self.recordValidationView = recordValidationView
    }
    
    public func didValidateRecord(_ isValid: Bool) {
        recordValidationView.display(RecordValidationViewModel(isValid: isValid))
    }
    
    public func didSaveRecordSuccessfully() {
        recordSaveView.display(RecordSaveViewModel(error: nil))
    }
    
    public func didSaveRecord(with error: Error) {
        recordSaveView.display(RecordSaveViewModel(error: error))
    }
}
