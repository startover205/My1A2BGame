//
//  RewardAdViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/9/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit
import MastermindiOS

public final class RewardAdViewController: ReplenishChanceDelegate {
    private let loader: RewardAdLoader
    private let rewardChanceCount: Int
    private weak var hostViewController: UIViewController?
    
    public init(loader: RewardAdLoader, rewardChanceCount: Int, hostViewController: UIViewController) {
        self.loader = loader
        self.rewardChanceCount = rewardChanceCount
        self.hostViewController = hostViewController
    }
    
    public func replenishChance(completion: @escaping (Int) -> Void) {
        guard let ad = loader.rewardAd, let hostVC = hostViewController else { return completion(0) }
        
        let rewardChanceCount = rewardChanceCount

        let alertMessage = String.localizedStringWithFormat(RewardAdPresenter.alertMessageFormat, rewardChanceCount)
        
        let alert = AlertAdCountdownController(
            title: RewardAdPresenter.alertTitle,
            message: alertMessage,
            cancelMessage: RewardAdPresenter.alertCancelTitle,
            countDownTime: RewardAdPresenter.alertCountDownTime,
            confirmHandler: { [weak hostVC] in
                guard let hostVC = hostVC else { return }
                
                ad.present(fromRootViewController: hostVC) {
                    completion(rewardChanceCount)
                }
            },
            cancelHandler: { completion(0) })
        
        hostVC.present(alert, animated: true)
    }
}