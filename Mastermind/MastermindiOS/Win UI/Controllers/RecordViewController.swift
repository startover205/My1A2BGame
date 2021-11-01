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
    var saveRecordButtonTitle: String { get }
    func didRequestValidateRecord()
    func didRequestSaveRecord(playerName: String)
}

public final class RecordViewController: NSObject {
    @IBOutlet private(set) public weak var confirmButton: UIButton!
    @IBOutlet private(set) public weak var containerView: UIStackView!
    @IBOutlet private(set) public weak var inputTextField: UITextField!
    @IBOutlet private(set) public weak var breakRecordMessageLabel: UILabel!
    
    public weak var hostViewController: UIViewController?
    public var delegate: RecordViewControllerDelegate?
    
    public func configureViews() {
        confirmButton.addTarget(self, action: #selector(insertRecord), for: .touchUpInside)
        
        confirmButton.setTitle(delegate?.saveRecordButtonTitle, for: .normal)
        
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
}

extension RecordViewController: RecordValidationView {
    public func display(_ viewModel: RecordValidationViewModel) {
        containerView.alpha = viewModel.isValid ? 1 : 0
        
        breakRecordMessageLabel.text = viewModel.message
    }
}

extension RecordViewController: RecordSaveView {
    public func display(_ viewModel: RecordSaveResultAlertViewModel) {
        if viewModel.success {
            containerView.alpha = 0
        }
        
        let alert = UIAlertController(
            title: viewModel.title,
            message: viewModel.message,
            preferredStyle: .alert)
        let confirm = UIAlertAction(
            title: viewModel.confirmTitle,
            style: .default)
        
        alert.addAction(confirm)
        
        hostViewController?.showDetailViewController(alert, sender: self)
    }
}
