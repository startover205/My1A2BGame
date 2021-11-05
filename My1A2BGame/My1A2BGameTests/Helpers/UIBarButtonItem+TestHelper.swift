//
//  UIBarButtonItem+TestHelper.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/11/5.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    func simulateTap() {
        target!.performSelector(onMainThread: action!, with: nil, waitUntilDone: true)
    }
}
