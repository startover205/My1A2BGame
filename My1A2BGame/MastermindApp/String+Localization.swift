//
//  String+Localization.swift
//  EasyTimer
//
//  Created by Ming-Ta Yang on 2019/3/25.
//  Copyright © 2019年 Sam's App Lab. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with comment: String) -> String {
        return NSLocalizedString(self, comment: comment)
    }
}
