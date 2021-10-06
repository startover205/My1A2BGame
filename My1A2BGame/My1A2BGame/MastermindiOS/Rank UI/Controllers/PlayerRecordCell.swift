//
//  PlayerRecordCell.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/3/26.
//  Copyright © 2019年 Ming-Ta Yang. All rights reserved.
//

import UIKit

public class PlayerRecordCell: UITableViewCell {
    @IBOutlet private(set) public weak var playerNameLabel: UILabel!
    @IBOutlet private(set) public weak var guessCountLabel: UILabel!
    @IBOutlet private(set) public weak var guessTimeLabel: UILabel!
}
