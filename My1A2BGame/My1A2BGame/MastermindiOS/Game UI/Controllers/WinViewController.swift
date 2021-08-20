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
    public var guessCount = 0
    public var guessTime = 99999.9
    public var digitCount = 4
    
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
}

