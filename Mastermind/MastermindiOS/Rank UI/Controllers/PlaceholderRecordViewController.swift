//
//  PlaceholderRecordViewController.swift
//  MastermindiOS
//
//  Created by Ming-Ta Yang on 2021/10/7.
//

import UIKit
import Mastermind

public final class PlaceholderRecordCellController: RecordCellController {
    private var cell: PlayerRecordCell?
    
    public init() {}
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        cell = (tableView.dequeueReusableCell(withIdentifier: "PlayerRecordCell") as! PlayerRecordCell)
        
        cell?.playerNameLabel.text = "-----"
        cell?.guessCountLabel.text = "--"
        cell?.guessTimeLabel.text = "--:--:--"
        return cell!
    }
}
