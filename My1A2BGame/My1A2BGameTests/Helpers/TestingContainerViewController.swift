//
//  TestingContainerViewController.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/11/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit

class TestingContainerViewController: UIViewController {
    convenience init(_ rootViewController: UIViewController) {
        self.init()
                
        addChild(rootViewController)
        rootViewController.view.frame = view.frame
        view.addSubview(rootViewController.view)
        rootViewController.didMove(toParent: self)
    }

    private var capturedPresentedViewController: UIViewController?

    override var presentedViewController: UIViewController? { capturedPresentedViewController }

    override func show(_ vc: UIViewController, sender: Any?) {
        capturedPresentedViewController = vc
    }

    override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        capturedPresentedViewController = vc
    }
}
