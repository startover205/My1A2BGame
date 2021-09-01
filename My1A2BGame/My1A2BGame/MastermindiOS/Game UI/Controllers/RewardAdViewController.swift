//
//  RewardAdViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/9/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit

public final class RewardAdViewController {
    init(adProvider: AdProvider, adRewardChance: Int, countDownTime: TimeInterval, onGrantReward: @escaping () -> Void, hostViewController: UIViewController? = nil) {
        self.adProvider = adProvider
        self.adRewardChance = adRewardChance
        self.countDownTime = countDownTime
        self.onGrantReward = onGrantReward
        self.hostViewController = hostViewController
    }
    
    private let adProvider: AdProvider
    private let adRewardChance: Int
    private let countDownTime: TimeInterval
    private let onGrantReward: () -> Void
    
    private weak var hostViewController: UIViewController?
    
    func adAvailable() -> Bool { adProvider.rewardAd != nil }
    
    func askUserToWatchAd(completion: @escaping (Bool) -> Void) {
        let format = NSLocalizedString("Do you want to watch a reward ad? Watching a reward ad will grant you %d chances!", comment: "")
        let message = String.localizedStringWithFormat(format, adRewardChance)
        let alert = AlertAdCountdownController(
            title: NSLocalizedString("You Are Out Of Chances...", comment: "2nd"),
            message: message,
            cancelMessage: NSLocalizedString("No, thank you", comment: "7th"),
            countDownTime: countDownTime,
            adHandler: { [weak self] in
                completion(true)
                self?.presentAd()
            },
            cancelHandler: {
                completion(false)
            })
    
        hostViewController?.present(alert, animated: true)
    }
    
    private func presentAd() {
        guard let ad = adProvider.rewardAd, let hostVC = hostViewController else { return }
        
        ad.present(fromRootViewController: hostVC) { [weak self] in
            // We need to keep the reference of the ad so the callback can be fired correctly.
            _ = ad
            
            self?.onGrantReward()
        }
    }
}
