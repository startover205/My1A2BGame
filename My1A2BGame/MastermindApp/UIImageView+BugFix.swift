//
//  UIImageView+BugFix.swift
//  EasyTimer
//
//  Created by Ming-Ta Yang on 2019/3/1.
//  Copyright © 2019年 Sam's App Lab. All rights reserved.
//

import UIKit

extension UIImageView {
    override open func awakeFromNib() {
        super.awakeFromNib()
        tintColorDidChange()
    }
}
