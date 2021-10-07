//
//  ModelRecordCellController.swift
//  MastermindiOS
//
//  Created by Ming-Ta Yang on 2021/10/7.
//

import UIKit
import Mastermind

public final class ModelRecordCellController: RecordCellController {
    private let model: PlayerRecord
    private var cell: PlayerRecordCell?
    private let formatter: DateComponentsFormatter
    
    public init(model: PlayerRecord, formatter: DateComponentsFormatter) {
        self.model = model
        self.formatter = formatter
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        cell = (tableView.dequeueReusableCell(withIdentifier: "PlayerRecordCell") as! PlayerRecordCell)
        
        cell?.playerNameLabel.text = model.playerName
        cell?.guessCountLabel.text = model.guessCount.description
        cell?.guessTimeLabel.text = formatter.string(from: model.guessTime)
        return cell!
    }
}
