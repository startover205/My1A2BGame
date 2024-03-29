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
    public var showFireworkAnimation: ((_ on: UIView) -> Void)?
    public var shareViewController: ShareViewController?
    public var viewModel: WinResultViewModel?
    @IBOutlet private(set) public weak var recordViewController: RecordViewController!
    
    @IBOutlet private(set) public weak var winLabel: UILabel!
    @IBOutlet private(set) public weak var guessCountLabel: UILabel!
    @IBOutlet private(set) public weak var emojiLabel: UILabel!
    
    private var isFirstTimeAppear = true
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = shareViewController?.view
        
        winLabel.text = viewModel?.winMessage
        guessCountLabel.text = viewModel?.guessCountMessage

        recordViewController?.configureViews()
        
        prepareEmoji()
        
        view.sendSubviewToBack(emojiLabel)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstTimeAppear {
            isFirstTimeAppear = false
            
            emojiAnimation()
            showFireworkAnimation?(self.view)
        }
    }
}

// MARK: - Private
private extension WinViewController {
    func prepareEmoji() {
        self.emojiLabel.transform = CGAffineTransform(translationX: 0, y:-view.frame.height)
    }
    func emojiAnimation() {
        UIView.animate(withDuration: 4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 3, options: [.curveEaseOut], animations: {
            
            self.emojiLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            
        })
    }
}

