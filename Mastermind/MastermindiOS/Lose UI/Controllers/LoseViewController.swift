//
//  LoseViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2018/7/17.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import UIKit
import Mastermind

public class LoseViewController: UIViewController {
    @IBOutlet private(set) public weak var emojiLabel: UILabel!
    @IBOutlet private(set) public weak var loseMessageLabel: UILabel!
    @IBOutlet private(set) public weak var encouragementMessageLabel: UILabel!
    
    public var viewModel: LoseViewModel?
    
    public var rainAnimation: ((_ on: UIView) -> Void)?
    
    private var isFirstTimeAppear = true
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        loseMessageLabel.text = viewModel?.loseMessage
        encouragementMessageLabel.text = viewModel?.encouragementMessage
        
        rainAnimation?(self.view)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstTimeAppear {
            isFirstTimeAppear = false
            
            emojiAnimation()
        }
    }
}

// MARK: - Private
private extension LoseViewController {
    func emojiAnimation(){
        UIView.animate(withDuration: 6, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 2, options: [], animations: {
            self.emojiLabel.transform = CGAffineTransform(translationX: 0, y: 10)
            self.emojiLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 9)
        })
    }
}
