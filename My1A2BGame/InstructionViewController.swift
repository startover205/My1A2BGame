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
        
        // Do any additional setup after loading the view.
        
        instructionTextView.text = NSLocalizedString("遊戲說明", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
