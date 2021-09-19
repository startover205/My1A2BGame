//
//  HelperViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/8/31.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit
import MastermindiOS

final class HelperViewController: NSObject {
    @IBOutlet weak var helperBoardView: UIView!
    @IBOutlet var helperNumberButtons: [HelperButton]!
    
    public var animate: Animate?
    public var onTapHelperInfo: (() -> Void)?
    
    @IBAction func helperBtnPressed(_ sender: Any) {
        if helperBoardView.isHidden {
            self.helperBoardView.isHidden = false
            self.helperBoardView.transform = .init(translationX: 0, y: -300)
            
            animate?(0.25, {
                self.helperBoardView.transform = .identity
            }, nil)
            
        } else {
            
            animate?(0.25, {
                self.helperBoardView.transform = .init(translationX: 0, y: -300)
            }, { _ in
                self.helperBoardView.isHidden = true
            })
        }
    }
    
    @IBAction func helperInfoBtnPressed(_ sender: Any) {
        onTapHelperInfo?()
    }
    
    @IBAction func helperResetBtnPressed(_ sender: Any) {
        helperNumberButtons.forEach { $0.reset() }
    }
    
    func hideView() {
        helperBoardView.isHidden = true
    }
}
