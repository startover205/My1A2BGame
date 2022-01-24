//
//  IAPViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/4/11.
//  Copyright © 2019 Ming-Ta Yang. All rights reserved.
//

import UIKit

public class IAPViewController: UITableViewController {
    
    @IBOutlet private(set) public weak var restorePurchaseButton: UIBarButtonItem!
    
    var tableModel = [IAPCellController]() {
        didSet {
            tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .left)
        }
    }
    var onRefresh: (() -> Void)?
    var onRestoreCompletedTransactions: (() -> Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
    }
    
    @IBAction func reloadProducts(_ sender: Any) {
        refresh()
    }
    
    @IBAction func restoreBtnPressed(_ sender: Any) {
        onRestoreCompletedTransactions?()
    }
    
    func refresh() {
        onRefresh?()
    }
    
    // MARK: - Table view data source
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    // MARK: - Table view delegate
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(at: indexPath).tableView(tableView, cellForRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellController(at: indexPath).tableView(tableView, didSelectRowAt: indexPath)
    }
    
    private func cellController(at indexPath: IndexPath) -> IAPCellController {
       tableModel[indexPath.row]
    }
}
