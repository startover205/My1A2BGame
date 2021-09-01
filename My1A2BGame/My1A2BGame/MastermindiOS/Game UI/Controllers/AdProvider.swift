//
//  RewardAdLoader.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/9/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import GoogleMobileAds

public protocol RewardAdLoader {
    var rewardAd: GADRewardedAd? { get }
}