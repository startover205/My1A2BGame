//
//  RankTableViewCell.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/3/26.
//  Copyright © 2019年 Ming-Ta Yang. All rights reserved.
//

import UIKit

class RankTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timesLabel: UILabel!
    @IBOutlet weak var spentTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
