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
    private var ad: RewardAd?
    
    public init(loader: RewardAdLoader, rewardChanceCount: Int, hostViewController: UIViewController) {
        self.loader = loader
        self.rewardChanceCount = rewardChanceCount
        self.hostViewController = hostViewController
        
        loader.load(completion: { [weak self] result in
            self?.ad = try? result.get()
        })
    }
    
    public func replenishChance(completion: @escaping (Int) -> Void) {
        guard let ad = ad, let hostVC = hostViewController else { return completion(0) }
        
        let rewardChanceCount = rewardChanceCount

        let alertMessage = String.localizedStringWithFormat(RewardAdPresenter.alertMessageFormat, rewardChanceCount)
        
        let alert = AlertAdCountdownController(
            title: RewardAdPresenter.alertTitle,
            message: alertMessage,
            cancelMessage: RewardAdPresenter.alertCancelTitle,
            countDownTime: RewardAdPresenter.alertCountDownTime,
            confirmHandler: { [weak hostVC, weak self] in
                guard let hostVC = hostVC else { return }
                
                ad.present(fromRootViewController: hostVC) {
                    completion(rewardChanceCount)
                }
                
                self?.loader.load(completion: { _ in })
            },
            cancelHandler: { completion(0) })
        
        hostVC.present(alert, animated: false)
    }
}
