//
//  InstructionViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2018/7/19.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import UIKit

public class InstructionViewController: UIViewController {
    @IBOutlet private(set) public weak var instructionTextView: UITextView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        instructionTextView.text = NSLocalizedString("     1A2B is a simple game to enjoy.\n     The computer will prepare a non-repeating four-digit nubmer (first digit could be 0). The player needs to find that very number.\n     The computer will provide hints according to the number inputted by the player. For example: \"1A2B\" means that there is one correct digit in its correct place while there are two correct digits in wrong places.\n     Try to guess the right number, compete with your friends, and enjoy!", comment: "")
    }
}
