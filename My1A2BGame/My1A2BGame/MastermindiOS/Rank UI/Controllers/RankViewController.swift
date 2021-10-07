//
//  RankViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/3/26.
//  Copyright © 2019年 Ming-Ta Yang. All rights reserved.
//

import UIKit
import Mastermind

public struct RankViewModel {
    public let records: [PlayerRecord]
}

public protocol RankView {
    func display(_ viewModel: RankViewModel)
}

public final class RankPresenter {
    private let rankView: RankView
    
    public init(rankView: RankView) {
        self.rankView = rankView
    }
    
    func didLoad(records: [PlayerRecord]) {
        rankView.display(RankViewModel(records: records))
    }
}

struct RecordViewModel {
    let record: PlayerRecord
}

protocol RecordCellController {
    func view(in tableView: UITableView) -> UITableViewCell
}

final class ModelRecordCellController: RecordCellController {
    private let model: PlayerRecord
    private var cell: PlayerRecordCell?
    private let formatter: DateComponentsFormatter
    
    init(model: PlayerRecord, formatter: DateComponentsFormatter) {
        self.model = model
        self.formatter = formatter
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = (tableView.dequeueReusableCell(withIdentifier: "PlayerRecordCell") as! PlayerRecordCell)
        
        cell?.playerNameLabel.text = model.playerName
        cell?.guessCountLabel.text = model.guessCount.description
        cell?.guessTimeLabel.text = formatter.string(from: model.guessTime)
        return cell!
    }
}

final class PlaceholderRecordCellController: RecordCellController {
    private var cell: PlayerRecordCell?
    
    init() {}
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = (tableView.dequeueReusableCell(withIdentifier: "PlayerRecordCell") as! PlayerRecordCell)
        
        cell?.playerNameLabel.text = "-----"
        cell?.guessCountLabel.text = "--"
        cell?.guessTimeLabel.text = "--:--:--"
        return cell!
    }
}

public class RankViewController: UIViewController {

    @IBOutlet private(set) public weak var gameTypeSegmentedControl: UISegmentedControl!
    @IBOutlet private(set) public weak var tableView: UITableView!
    
    var tableModel = [RecordCellController]() {
        didSet { tableView.reloadData() }
    }
    var loadRank: ((_ isAdvancedVersion: Bool) -> Void)?

    var isAdvancedVersion: Bool {
        return gameTypeSegmentedControl.selectedSegmentIndex == 1
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadRank?(isAdvancedVersion)
    }
    
    @IBAction func didChangeScope(_ sender: Any) {
        loadRank?(isAdvancedVersion)
    }
}

extension RankViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
}


extension RankViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableModel[indexPath.row].view(in: tableView)
    }
}
