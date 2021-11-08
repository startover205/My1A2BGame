//
//  MoreViewController.swift
//  EasyTimer
//
//  Created by Ming-Ta Yang on 2019/3/20.
//  Copyright © 2019年 Sam's App Lab. All rights reserved.
//

import UIKit

struct MoreItem {
    let name: String
    let image: UIImage
    let selection: (_ anchorView: UIView?) -> Void
}

public class MoreViewController: UITableViewController {
    
    var tableModel = [MoreItem]()
    
    // MARK: - Table view data source
    public override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = tableModel[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        cell.textLabel?.text = item.name
        cell.imageView?.image = item.image
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableModel[indexPath.row].selection(cell)
    }
}
