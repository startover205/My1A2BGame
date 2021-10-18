//
//  UIViewControllerSpy.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/10/18.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit

final class UIViewControllerSpy: UIViewController {
    var presentCallCount: Int { capturedPresentations.count }
    private(set) var capturedPresentations = [(vc: UIViewController, animated: Bool, completion: (() -> Void)?)]()
    private(set) var capturedDismissals = [(animated: Bool, completion: (() -> Void)?)]()
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        capturedPresentations.append((viewControllerToPresent, flag, completion))
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        capturedDismissals.append((flag, completion))
    }
}
