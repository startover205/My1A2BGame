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
    
    private struct NoAdAvailable: Error {}
    
    var rewardAd: RewardAd? { ad }
    
    init(ad: RewardAd?) {
        self.ad = ad
    }
    
    func load(completion: @escaping (RewardAdLoader.Result) -> Void) {
        if let ad = ad {
            completion(.success(ad))
        } else {
            completion(.failure(NoAdAvailable()))
        }
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
