//
//  RewardAdViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/9/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit
import MastermindiOS

public final class RewardAdViewController {
    init(loader: RewardAdLoader, adRewardChance: Int, countDownTime: TimeInterval, hostViewController: UIViewController) {
        self.loader = loader
        self.adRewardChance = adRewardChance
        self.countDownTime = countDownTime
        self.hostViewController = hostViewController
    }
    
    private let loader: RewardAdLoader
    private let adRewardChance: Int
    private let countDownTime: TimeInterval
    
    private weak var hostViewController: UIViewController?
}

extension RewardAdViewController: ReplenishChanceDelegate {
    public func replenishChance(completion: @escaping (Int) -> Void) {
        guard let ad = loader.rewardAd, let hostVC = hostViewController else { return completion(0) }
        
        let adRewardChance = self.adRewardChance
        
        let format = NSLocalizedString("Do you want to watch a reward ad? Watching a reward ad will grant you %d chances!", comment: "")
        let message = String.localizedStringWithFormat(format, adRewardChance)
        let alert = AlertAdCountdownController(
            title: NSLocalizedString("You Are Out Of Chances...", comment: "2nd"),
            message: message,
            cancelMessage: NSLocalizedString("No, thank you", comment: "7th"),
            countDownTime: countDownTime,
            adHandler: {
                ad.present(fromRootViewController: hostVC) {
                    _ = ad
                    
                    completion(adRewardChance)
                }
            },
            cancelHandler: {
                completion(0)
            })
    
        hostViewController?.present(alert, animated: true)
    }
}
