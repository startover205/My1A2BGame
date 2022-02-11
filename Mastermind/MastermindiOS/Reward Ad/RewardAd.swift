//
//  RewardAd.swift
//  MastermindiOS
//
//  Created by Ming-Ta Yang on 2022/2/11.
//

import UIKit

public protocol RewardAd {
    func present(fromRootViewController rootViewController: UIViewController, userDidEarnRewardHandler: @escaping () -> Void)
}
