//
//  RecordCellController.swift
//  MastermindiOS
//
//  Created by Ming-Ta Yang on 2021/10/7.
//

import UIKit

public protocol RecordCellController {
    func view(in tableView: UITableView) -> UITableViewCell
}
