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
    
    override func viewDidLoad() {
        super.viewDidLoad()

            adBannerView.rootViewController = self
            adBannerView.adUnitID = Constants.bottomAdId
            adBannerView.load(GADRequest())
    }
}
