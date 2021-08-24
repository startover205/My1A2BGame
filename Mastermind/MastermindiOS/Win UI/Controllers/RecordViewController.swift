//
//  RecordViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/8/19.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit

public final class RecordViewController: NSObject {
    @IBOutlet private(set) public weak var confirmButton: UIButton!
    @IBOutlet private(set) public weak var containerView: UIStackView!
    @IBOutlet private(set) public weak var inputTextField: UITextField!
    
    public weak var hostViewController: UIViewController?
    public var recordViewModel: RecordViewModel?
    
    public func configureViews() {
        bindViews()
        
        recordViewModel?.validateRecord()
    }
    
    private func bindViews() {
        confirmButton.addTarget(self, action: #selector(insertRecord), for: .touchUpInside)
        
        recordViewModel?.onValidation = { [weak self] breakRecord in
            self?.containerView.alpha = breakRecord ? 1 : 0
        }
        
        recordViewModel?.onSave = { [weak self] error in
            if let error = error {
                self?.showAlert(title: NSLocalizedString("Failed to Make a Record", comment: "2nd"), message: error.localizedDescription)
            } else {
                self?.containerView.alpha = 0
                self?.showAlert(title: NSLocalizedString("Record Complete!", comment: "2nd"))
            }
        }
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
        
        recordViewModel?.insertRecord(playerName: name)
    }
    
    private func showAlert(title: String, message: String? = nil, onDismiss: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "2nd"), style: .default, handler: onDismiss)
        alert.addAction(ok)
        
        hostViewController?.present(alert, animated: true, completion: nil)
    }
}
