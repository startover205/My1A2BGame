//
//  InstructionViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2018/7/19.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import UIKit

class InstructionViewController: UIViewController {
    @IBOutlet weak var instructionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instructionTextView.text = NSLocalizedString("遊戲說明", comment: "")
    }
}
