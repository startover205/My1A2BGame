//
//  RankViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/3/26.
//  Copyright © 2019年 Ming-Ta Yang. All rights reserved.
//

import UIKit

public class RankViewController: UIViewController {

    private(set) public var gameTypeSegmentedControl: UISegmentedControl!
    @IBOutlet private(set) public weak var tableView: UITableView!
    
    public var tableModel = [RecordCellController]() {
        didSet { tableView.reloadData() }
    }
    public var loadRank: ((_ isAdvancedVersion: Bool) -> Void)?

    var isAdvancedVersion: Bool {
        return gameTypeSegmentedControl.selectedSegmentIndex == 1
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let items = ["Basic", "Advanced"]
        gameTypeSegmentedControl = UISegmentedControl(items: items)
        gameTypeSegmentedControl.selectedSegmentIndex = 0
        gameTypeSegmentedControl.addTarget(self, action: #selector(didChangeScope(_:)), for: .valueChanged)
        navigationItem.titleView = gameTypeSegmentedControl
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadRank?(isAdvancedVersion)
    }
    
    @objc func didChangeScope(_ sender: Any) {
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
