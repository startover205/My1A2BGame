//
//  UIViewController+TestHelpers.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/12/12.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit

extension UIViewController {
    func simulateViewAppear() {
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func simulateViewDisappear() {
        beginAppearanceTransition(false, animated: false)
        endAppearanceTransition()
    }
}
