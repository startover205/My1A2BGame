//
//  BannerAdTabBarViewController.swift
//  EasyTimer
//
//  Created by Ming-Ta Yang on 2019/8/27.
//  Copyright © 2019 Sam's App Lab. All rights reserved.
//

import UIKit

class BannerAdTabBarViewController: UITabBarController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 11.0, *), !AdControl.isBottomAdRemoved() {
            var newSafeArea = UIEdgeInsets()
            let bannerHeight = AdControl.setBannerAd(onTopOf: tabBar, rootController: self)
            newSafeArea.bottom += bannerHeight
            
            for child in childViewControllers {
                child.additionalSafeAreaInsets = newSafeArea
            }
        }
    }
}
