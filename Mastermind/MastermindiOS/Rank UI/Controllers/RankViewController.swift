//
//  RankViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/3/26.
//  Copyright © 2019年 Ming-Ta Yang. All rights reserved.
//

import UIKit
import Mastermind

public struct RecordViewModel {
    public init(playerName: String, guessCount: String, guessTime: String) {
        self.playerName = playerName
        self.guessCount = guessCount
        self.guessTime = guessTime
    }
    
    public let playerName: String
    public let guessCount: String
    public let guessTime: String
}

public class RankViewController: UIViewController {

    @IBOutlet private(set) public weak var gameTypeSegmentedControl: UISegmentedControl!
    @IBOutlet private(set) public weak var tableView: UITableView!
    
    public var tableModel = [RecordCellController]() {
        didSet { tableView.reloadData() }
    }
    public var loadRank: ((_ isAdvancedVersion: Bool) -> Void)?

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
