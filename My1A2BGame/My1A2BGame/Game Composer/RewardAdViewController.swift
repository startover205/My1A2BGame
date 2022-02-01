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
    private let asyncAfter: AsyncAfter
    
    public init(loader: RewardAdLoader,
                rewardChanceCount: Int,
                hostViewController: UIViewController,
                asyncAfter: @escaping AsyncAfter = {
        DispatchQueue.main.asyncAfter(deadline: .now() + $0, execute: $1)
    }) {
        self.loader = loader
        self.rewardChanceCount = rewardChanceCount
        self.hostViewController = hostViewController
        self.asyncAfter = asyncAfter
        
        loadAd()
    }
    
    public func replenishChance(completion: @escaping (Int) -> Void) {
        guard let ad = preparedAd, let hostVC = hostViewController else { return completion(0) }
        
        let rewardChanceCount = rewardChanceCount

        let alertMessage = String.localizedStringWithFormat(RewardAdPresenter.alertMessageFormat, rewardChanceCount)
        
        let alert = CountdownAlertController(
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
            },
            asyncAfter: asyncAfter)
        
        hostVC.present(alert, animated: true)
    }
    
    private func loadAd() {
        loader.load(completion: { [weak self] result in
            self?.preparedAd = try? result.get()
        })
    }
}
