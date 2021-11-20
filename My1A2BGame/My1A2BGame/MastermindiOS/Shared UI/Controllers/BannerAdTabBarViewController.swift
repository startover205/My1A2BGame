//
//  BannerAdTabBarViewController.swift
//  EasyTimer
//
//  Created by Ming-Ta Yang on 2019/8/27.
//  Copyright © 2019 Sam's App Lab. All rights reserved.
//

import UIKit

class BannerAdTabBarViewController: UITabBarController {
    var isBottomADRemoved: () -> Bool = { false }
    
    convenience init(isBottomADRemoved: @escaping () -> Bool = { false }) {
        self.init()
        self.isBottomADRemoved = isBottomADRemoved
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 11.0, *), !isBottomADRemoved() {
            var newSafeArea = UIEdgeInsets()
            let bannerHeight = AdControl.setBannerAd(onTopOf: tabBar, rootController: self)
            newSafeArea.bottom += bannerHeight
            
            for child in children {
                child.additionalSafeAreaInsets = newSafeArea
            }
        }
    }
}
