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
    private var preparedAd: RewardAd?
    private var currentDisplayingAd: RewardAd?
    
    public init(loader: RewardAdLoader, rewardChanceCount: Int, hostViewController: UIViewController) {
        self.loader = loader
        self.rewardChanceCount = rewardChanceCount
        self.hostViewController = hostViewController
        
        loadAd()
    }
    
    public func replenishChance(completion: @escaping (Int) -> Void) {
        guard let ad = preparedAd, let hostVC = hostViewController else { return completion(0) }
        
        let rewardChanceCount = rewardChanceCount

        let alertMessage = String.localizedStringWithFormat(RewardAdPresenter.alertMessageFormat, rewardChanceCount)
        
        let alert = AlertAdCountdownController(
            title: RewardAdPresenter.alertTitle,
            message: alertMessage,
            cancelAction: RewardAdPresenter.alertCancelTitle,
            countdownTime: RewardAdPresenter.alertCountDownTime,
            onConfirm: { [weak hostVC, weak self] in
                guard let hostVC = hostVC, let self = self else { return }
                
                hostVC.dismiss(animated: true) {
                    self.currentDisplayingAd = ad
                    self.preparedAd = nil
                    
                    ad.present(fromRootViewController: hostVC) { [weak self] in
                        completion(rewardChanceCount)
                        
                        self?.currentDisplayingAd = nil
                    }
                    
                    self.loadAd()
                }
            },
            onCancel: { [weak hostVC] in
                hostVC?.dismiss(animated: true) { completion(0) }
            })
        
        hostVC.present(alert, animated: true)
    }
    
    private func loadAd() {
        loader.load(completion: { [weak self] result in
            self?.preparedAd = try? result.get()
        })
    }
}
