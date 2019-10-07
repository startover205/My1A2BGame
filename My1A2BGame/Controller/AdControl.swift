//
//  LiteControl.swift
//  EasyTimer
//
//  Created by Ming-Ta Yang on 2019/8/27.
//  Copyright © 2019 Sam's App Lab. All rights reserved.
//

import GoogleMobileAds

enum AdControl {
    
}

// MARK: - Ad
extension AdControl {
    static func setupAd(){
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    static func setBannerAd(onTopOf view: UIView, rootController: UIViewController) -> CGFloat {
        let googleBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        googleBannerView.rootViewController = rootController
        googleBannerView.adUnitID = Constants.bottomAdId
        googleBannerView.load(GADRequest())
        
        view.addSubview(googleBannerView)
        googleBannerView.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: googleBannerView.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: googleBannerView.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: googleBannerView.rightAnchor).isActive = true
        
        return googleBannerView.frame.height
    }
    
    static func isBottomAdRemoved() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaults.Key.remove_bottom_ad)
    }
}
