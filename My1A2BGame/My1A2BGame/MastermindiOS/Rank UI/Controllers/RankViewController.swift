//
//  RankViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/3/26.
//  Copyright © 2019年 Ming-Ta Yang. All rights reserved.
//

import UIKit
import Mastermind

public protocol User {
    var date: Date { get set }
    var guessTimes: Int16 { get set }
    var name: String { get set }
    var spentTime: Double { get set }
}

extension Winner: User {}
extension AdvancedWinner: User {}

public class RankViewController: UIViewController {

    @IBOutlet private(set) public weak var gameTypeSegmentedControl: UISegmentedControl!
    @IBOutlet private(set) public weak var tableView: UITableView!
    
    var objects = [PlayerRecord]()
    
    public var requestRecords: (() -> [User])!
    public var requestAdvancedRecord: (() -> [User])!
    
    var isAdvancedVersion: Bool {
        return gameTypeSegmentedControl.selectedSegmentIndex == 1
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
    }
    
    @IBAction func didChangeScope(_ sender: Any) {
        refresh()
    }
}

extension RankViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if objects.isEmpty {
            return 1
        }
        return objects.count
    }
}


extension RankViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankTableViewCell", for: indexPath) as! RankTableViewCell
        
        guard !objects.isEmpty else {
            cell.nameLabel.text = "-----"
            cell.timesLabel.text = "--"
            cell.spentTimeLabel.text = "--:--:--"
            return cell
        }
        
        let record = objects[indexPath.row]
        cell.nameLabel.text = record.playerName
        cell.timesLabel.text = record.guessCount.description
        cell.spentTimeLabel.text = getTimeString(with: record.guessTime)
        return cell
    }
}

private extension RankViewController {
    func refresh() {
        if isAdvancedVersion{
            objects = requestAdvancedRecord().toModel()
        } else {
            objects = requestRecords().toModel()
        }
        
        tableView.reloadData()
    }
    
    func getTimeString(with timeInterval: Double) -> String {
        let time = Int(timeInterval)
        var hour = time / 3600
        let second = time % 60
        let minute = time / 60 % 60
        
        if hour > 99 {
            hour = 99
        }
        
        return String(format:"%02d:%02d:%02d", hour, minute, second)
    }
}

private extension Array where Element == User {
    func toModel() -> [PlayerRecord] {
        map { 
            .init(playerName: $0.name, guessCount: Int($0.guessTimes), guessTime: $0.spentTime, timestamp: $0.date)
        }
    }
}
