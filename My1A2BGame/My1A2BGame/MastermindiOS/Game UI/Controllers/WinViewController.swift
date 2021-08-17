//
//  WinViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2018/5/31.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import UIKit
import Mastermind

public class WinViewController: UIViewController {
    
    public typealias ReviewCompletion = () -> Void

    public var guessCount = 0
    public var spentTime = 99999.9
    public var isAdvancedVersion = false
    
    public var recordLoader: RecordLoader?
    public var userDefaults: UserDefaults?
    public var askForReview: ((@escaping ReviewCompletion) -> Void)?
    public var showFireworkAnimation: ((_ on: UIView) -> Void)?
    public var shareViewController: ShareViewController?
    
    @IBOutlet private(set) public weak var winLabel: UILabel!
    @IBOutlet private(set) public weak var guessCountLabel: UILabel!
    @IBOutlet private(set) public weak var emojiLabel: UILabel!
    @IBOutlet private(set) public weak var nameTextField: UITextField!
    @IBOutlet private(set) public weak var confirmBtn: UIButton!
    @IBOutlet private(set) public weak var newRecordStackView: UIStackView!
    @IBOutlet private(set) public weak var shareBarBtnItem: UIBarButtonItem!
    @IBAction func dismissKeyboard(_ sender: UITextField) {
    }
    @IBAction func didTapScreen(_ sender: Any) {
        view.endEditing(true)
    }
    
    private lazy var _prepareEmoji: Void = {
        prepareEmoji()
    }()
    private lazy var _emojiAnimation: Void = {
        emojiAnimation()
    }()
    private lazy var _fireworkAnimation: Void = {
        showFireworkAnimation?(self.view)
    }()
    
    public convenience init(guessCount: Int, spentTime: TimeInterval, isAdvancedVersion: Bool) {
        self.init()
        self.guessCount = guessCount
        self.spentTime = spentTime
        self.isAdvancedVersion = isAdvancedVersion
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = shareViewController?.view
        
        showResult()
        
        if recordLoader?.validateNewRecord(with: PlayerRecord(playerName: "N/A", guessCount: guessCount, guessTime: spentTime, timestamp: Date())) == true {
            newRecordStackView.alpha = 1
        } else {
            newRecordStackView.alpha = 0
        }
        
        if isAdvancedVersion {
            winLabel.text =  NSLocalizedString("5A0B!! You won!!", comment: "")
        } else {
            winLabel.text =  NSLocalizedString("4A0B!! You won!!", comment: "")
        }
        
        _ = _prepareEmoji
        
        if #available(iOS 10.3, *) {
            tryToAskForReview()
        } 
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = _emojiAnimation
        _ = _fireworkAnimation
    }
    
    @IBAction func confirmBtnPressed(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        
        saveRecord(PlayerRecord(playerName: name, guessCount: guessCount, guessTime: spentTime, timestamp: Date()))
    }
}

// MARK: - UITextFieldDelegate
extension WinViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldString = textField.text! as NSString
        let newString = oldString.replacingCharacters(in: range, with: string)
        
        confirmBtn.isEnabled = !newString.isEmpty
        
        return true
    }
}

// MARK: - Core Data
private extension WinViewController {
    func saveRecord(_ record: PlayerRecord) {
        do {
            try recordLoader?.insertNewRecord(record)
            
            showAlert(title: NSLocalizedString("Record Complete!", comment: "2nd")) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
        } catch {
            showAlert(title: NSLocalizedString("Failed to Make a Record", comment: "2nd"), message: error.localizedDescription)
        }
    }
    
    private func showAlert(title: String, message: String? = nil, onDismiss: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "2nd"), style: .default, handler: onDismiss)
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Private
private extension WinViewController {
    func showResult(){
        let format = NSLocalizedString("You guessed %d times", comment: "")
        guessCountLabel.text = String.localizedStringWithFormat(format, guessCount)
    }
    
    func prepareEmoji(){
        self.emojiLabel.transform = CGAffineTransform(translationX: 0, y:-view.frame.height)
    }
    func emojiAnimation(){
        UIView.animate(withDuration: 4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 3, options: [.curveEaseOut], animations: {
            
            self.emojiLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            
        })
    }
    
    func tryToAskForReview(){
        
        var count = userDefaults?.integer(forKey: UserDefaults.Key.processCompletedCount) ?? 0
        count += 1
        userDefaults?.set(count, forKey: UserDefaults.Key.processCompletedCount)
        
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            assertionFailure("Expected to find a bundle version in the info dictionary")
            return
        }
        
        let lastVersionPromptedForReview = userDefaults?.string(forKey: UserDefaults.Key.lastVersionPromptedForReview)
        
        if count >= 3 && currentVersion != lastVersionPromptedForReview {
            askForReview? { [weak self] in
                self?.userDefaults?.set(currentVersion, forKey: UserDefaults.Key.lastVersionPromptedForReview)
            }
        }
    }
}

