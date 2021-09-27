//
//  RewardAdLoaderStub.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/9/27.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import MastermindiOS

class RewardAdLoaderStub: RewardAdLoader {
    private let ad: RewardAd?
    
    var rewardAd: RewardAd? { ad }
    
    init(ad: RewardAd?) {
        self.ad = ad
    }
}

extension RewardAdLoaderStub {
    static var null: RewardAdLoaderStub {
        .init(ad: nil)
    }
    
    static func providing(_ stub: RewardAd) -> RewardAdLoaderStub {
        .init(ad: stub)
    }
}
