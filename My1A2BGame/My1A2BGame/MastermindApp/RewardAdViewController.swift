//
//  RewardAdViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/9/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit
import MastermindiOS

public final class RewardAdPresenter {
    private init() {}
    
    public static var alertTitle: String {
        NSLocalizedString("ALERT_TITLE",
                          tableName: "RewardAd",
                          bundle: Bundle(for: RewardAdPresenter.self),
                          comment: "Title for reward ad alert")
    }
    
    public static var alertMessage: String {
        NSLocalizedString("ALERT_Message",
                          tableName: "RewardAd",
                          bundle: Bundle(for: RewardAdPresenter.self),
                          comment: "Message for reward ad alert")
    }
    
    public static var alertCancelTitle: String {
        NSLocalizedString("ALERT_CANCEL_TITLE",
                          tableName: "RewardAd",
                          bundle: Bundle(for: RewardAdPresenter.self),
                          comment: "Cancel title for reward ad alert")
    }
    
    public static var alertCountDownTime: TimeInterval { 5.0 }
}

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

        let alert = AlertAdCountdownController(
            title: RewardAdPresenter.alertTitle,
            message: RewardAdPresenter.alertMessage,
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
