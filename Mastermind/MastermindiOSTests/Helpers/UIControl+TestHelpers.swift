//
//  UIControl+TestHelpers.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/7/30.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0), with: self)
            }
        }
    }
}
