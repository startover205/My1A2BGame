//
//  GoogleRewardAdLoader.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2022/1/5.
//  Copyright © 2022 Ming-Ta Yang. All rights reserved.
//

import MastermindiOS
import GoogleMobileAds

public final class GoogleRewardAdLoader: RewardAdLoader {
    private let adUnitID: String
    
    public init(adUnitID: String) {
        self.adUnitID = adUnitID
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public func load(completion: @escaping (RewardAdLoader.Result) -> Void) {
        GADRewardedAd.load(withAdUnitID: adUnitID, request: nil) { [weak self] ad, error in
            guard self != nil else { return }
            
            completion(Result {
                if let error = error {
                    throw error
                } else if let ad = ad {
                    return ad
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }
    }
}
