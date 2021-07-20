//
//  GoogleRewardAdManager.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/4/6.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import GoogleMobileAds

class GoogleRewardAdManager: NSObject {
    static let shared = GoogleRewardAdManager()
    private override init() {}
    
    private let reachability = Reachability.forInternetConnection()
    
    private var internetAvailable: Bool { reachability?.currentReachabilityStatus() ?? NotReachable != NotReachable }
    
    /// 避免多次 load 廣告
    private let retrieveLock = NSLock()
    
    private(set) var rewardAd: GADRewardedAd?
    
    /// 開始下載廣告、監聽網路狀況
    func begin() {
        NotificationCenter.default.addObserver(forName: .reachabilityChanged, object: nil, queue: nil) { [weak self] (_) in
            print("---internet changed----", .error)
            
            self?.tryToLoadRewardAd()
        }
        reachability?.startNotifier()
        
        tryToLoadRewardAd()
    }
    
    private func reload() {
        rewardAd = nil
        
        tryToLoadRewardAd()
    }
    
    private func tryToLoadRewardAd(){
        guard rewardAd == nil, internetAvailable, retrieveLock.try() else { return }
        
        print("---開始讀取廣告----", .error)
        
        GADRewardedAd.load(withAdUnitID: Constants.rewardAdId, request: .init()) { [weak self] (ad, error) in
            
            guard let self = self else { return }
            
            
            if let error = error {
                print("讀取廣告失敗: \(error.localizedDescription)")
                return
            }
            self.rewardAd = ad
            ad?.fullScreenContentDelegate = self
            print("Rewarded ad loaded.")
            
            self.retrieveLock.unlock()
        }
        
    }
}


// MARK: - GADFullScreenContentDelegate
extension GoogleRewardAdManager: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("讀取獎勵廣告失敗：\(error)")
        tryToLoadRewardAd()
    }
    
    // 一旦使用過則不能再用，直接 reload
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("--adDidPresentFullScreenContent----", .error)
        
        reload()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        // 有 bug，不會被呼叫...
        print("---adDidDismissFullScreenContent----", .error)
        
        //        Self.tryToLoadRewardAd()
    }
}

extension GoogleRewardAdManager: AdProvider { }
