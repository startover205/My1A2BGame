//
//  WaitingViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/4/4.
//  Copyright © 2019年 Ming-Ta Yang. All rights reserved.
//

import UIKit

class WaitingViewController: UIViewController {
    
    init(){
        super.init(nibName: String(describing: WaitingViewController.self), bundle: nil)
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
