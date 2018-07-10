//
//  TableViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2018/7/10.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewDidAppear(_ animated: Bool) {
        
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "InitialController") else {
            return
        }
        
        present(controller, animated: false, completion: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  

}
