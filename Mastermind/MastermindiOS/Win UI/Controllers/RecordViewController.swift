//
//  RecordViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/8/19.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit
import Mastermind

public final class RecordViewController: NSObject {
    @IBOutlet private(set) public weak var confirmButton: UIButton!
    @IBOutlet private(set) public weak var containerView: UIStackView!
    @IBOutlet private(set) public weak var inputTextField: UITextField!
    
    public weak var hostViewController: UIViewController?
    public var guessCount: (() -> Int)!
    public var spentTime: (() -> TimeInterval)!
    public var loader: RecordLoader!
    public var currentDate: (() -> Date)!

    public func configureViews() {
        confirmButton.addTarget(self, action: #selector(insertRecord), for: .touchUpInside)
        
        containerView.alpha = loader.validate(score: (guessCount(), spentTime())) ? 1 : 0
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
        
        saveRecord(PlayerRecord(playerName: name, guessCount: guessCount(), guessTime: spentTime(), timestamp: currentDate()))
    }
    
    private func saveRecord(_ record: PlayerRecord) {
        do {
            try loader.insertNewRecord(record)
            
            showAlert(title: NSLocalizedString("Record Complete!", comment: "2nd")) { [weak self] _ in
                self?.hostViewController?.navigationController?.popViewController(animated: true)
            }
        } catch {
            showAlert(title: NSLocalizedString("Failed to Make a Record", comment: "2nd"), message: error.localizedDescription)
        }
    }
    
    private func showAlert(title: String, message: String? = nil, onDismiss: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "2nd"), style: .default, handler: onDismiss)
        alert.addAction(ok)
        
        hostViewController?.present(alert, animated: true, completion: nil)
    }
}