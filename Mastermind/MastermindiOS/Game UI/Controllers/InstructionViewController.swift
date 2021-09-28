//
//  InstructionViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2018/7/19.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import UIKit
import Mastermind

public class InstructionViewController: UIViewController {
    @IBOutlet private(set) public weak var instructionTextView: UITextView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        instructionTextView.text = GameInstructionPresenter.instruction
    }
}
