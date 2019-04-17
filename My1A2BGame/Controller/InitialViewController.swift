//
//  InitialViewController.swift
//  EasyTimer
//
//  Created by Ming-Ta Yang on 2019/3/18.
//  Copyright © 2019年 Sam's App Lab. All rights reserved.
//

import UIKit
import GoogleMobileAds

class InitialViewController: UIViewController {
    @IBOutlet weak var adBannerView: GADBannerView!
    @IBOutlet weak var adBannerHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isBottomAdRemoved(){
            adBannerHeightConstraint.constant = 0
        } else {
            IAP.bottomAdHightConstraint = adBannerHeightConstraint
            
            adBannerView.rootViewController = self
            adBannerView.adUnitID = Constants.bottomAdId
            
            if AppDelegate.internetAvailable(){
                adBannerView.load(GADRequest())
            } else {
                NotificationCenter.default.addObserver(self, selector: #selector(tryToLoadBottomAd), name: NSNotification.Name.reachabilityChanged, object: nil)
            }
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    @objc
    func tryToLoadBottomAd(){
        if AppDelegate.internetAvailable() {
            adBannerView.load(GADRequest())
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.reachabilityChanged, object: nil)
        }
    }
}

// MARK: - Private
private extension InitialViewController {
    func isBottomAdRemoved() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaults.Key.remove_bottom_ad)
    }
}
