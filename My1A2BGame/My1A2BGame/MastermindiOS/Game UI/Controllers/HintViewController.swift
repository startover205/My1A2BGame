//
//  HintViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/9/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit
import MastermindiOS

public final class HintViewController: NSObject {
    @IBOutlet private(set) public weak var hintLabel: UILabel!
    @IBOutlet private(set) public weak var hintTextView: UITextView!
    
    public var animate: Animate?

    private var oldHint = ""
    
    func configureViews() {
        hintLabel.text = ""
        hintTextView.text = ""
    }

    func updateHint(_ hint: String) {
        hintLabel.isHidden = false
        hintLabel.text = hint
        hintTextView.text = "\n" + oldHint
        
        oldHint = hint + oldHint
        
        flashHintLabel()
    }

    private func flashHintLabel() {
        hintLabel.alpha = 0.5
        animate?(0.5, { [weak self] in
            self?.hintLabel.alpha = 1
        }, nil)
    }
}
