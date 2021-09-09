//
//  RecordViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/8/19.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit
import Mastermind

public protocol RecordViewControllerDelegate {
    func didRequestValidateRecord()
    func didRequestSaveRecord(playerName: String)
}

public final class RecordViewController: NSObject {
    @IBOutlet private(set) public weak var confirmButton: UIButton!
    @IBOutlet private(set) public weak var containerView: UIStackView!
    @IBOutlet private(set) public weak var inputTextField: UITextField!
    
    public weak var hostViewController: UIViewController?
    public var delegate: RecordViewControllerDelegate?
    
    public func configureViews() {
        confirmButton.addTarget(self, action: #selector(insertRecord), for: .touchUpInside)
        
        delegate?.didRequestValidateRecord()
    }
    
    @IBAction private func dismissKeyboard(_ sender: UITextField) {
    }
    @IBAction public func didTapScreen(_ sender: Any) {
        hostViewController?.view.endEditing(true)
    }
    @IBAction private func didChangeInput(_ sender: UITextField) {
        confirmButton.isEnabled = sender.text?.isEmpty == false
    }
    
    @objc func insertRecord() {
        guard let name = inputTextField.text, !name.isEmpty else { return }
        
        inputTextField.resignFirstResponder()
        
        delegate?.didRequestSaveRecord(playerName: name)
    }
    
    private func showAlert(title: String, message: String? = nil, onDismiss: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "2nd"), style: .default, handler: onDismiss)
        alert.addAction(ok)
        
        hostViewController?.present(alert, animated: true, completion: nil)
    }
}

extension RecordViewController: RecordValidationView {
    public func display(_ viewModel: RecordValidationViewModel) {
        containerView.alpha = viewModel.isValid ? 1 : 0
    }
}

extension RecordViewController: RecordSaveView {
    public func display(_ viewModel: RecordSaveViewModel) {
        if let error = viewModel.error {
            showAlert(title: NSLocalizedString("Failed to Make a Record", comment: "2nd"), message: error.localizedDescription)
        } else {
            containerView.alpha = 0
            showAlert(title: NSLocalizedString("Record Complete!", comment: "2nd"))
        }
    }
}
