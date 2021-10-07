//
//  RecordCellController.swift
//  MastermindiOS
//
//  Created by Ming-Ta Yang on 2021/10/7.
//

import UIKit
import Mastermind

public final class RecordCellController {
    private let viewModel: RecordViewModel
    private var cell: PlayerRecordCell?
    
    public init(viewModel: RecordViewModel) {
        self.viewModel = viewModel
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        cell = (tableView.dequeueReusableCell(withIdentifier: "PlayerRecordCell") as! PlayerRecordCell)
        
        cell?.playerNameLabel.text = viewModel.playerName
        cell?.guessCountLabel.text = viewModel.guessCount
        cell?.guessTimeLabel.text = viewModel.guessTime
        return cell!
    }
}
