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
    public var digitCount = 4
    
    public var userDefaults: UserDefaults?
    public var askForReview: ((@escaping ReviewCompletion) -> Void)?
    public var showFireworkAnimation: ((_ on: UIView) -> Void)?
    public var shareViewController: ShareViewController?
    @IBOutlet private(set) public weak var recordViewController: RecordViewController!
    
    @IBOutlet private(set) public weak var winLabel: UILabel!
    @IBOutlet private(set) public weak var guessCountLabel: UILabel!
    @IBOutlet private(set) public weak var emojiLabel: UILabel!
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = shareViewController?.view
        
        showResult()

        recordViewController?.configureViews()
        
        let format = NSLocalizedString("%dA0B!! You won!!", comment: "2nd")
        winLabel.text = String.localizedStringWithFormat(format, digitCount)
        
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

