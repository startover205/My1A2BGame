//
//  RewardAdControllerComposer.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2022/1/11.
//  Copyright © 2022 Ming-Ta Yang. All rights reserved.
//

import Foundation
import MastermindiOS
import UIKit

final class RewardAdControllerComposer {
    static func rewardAdComposedWith(
        loader: RewardAdLoader,
        rewardChanceCount: Int,
        hostViewController: UIViewController,
        asyncAfter: @escaping AsyncAfter = {
            DispatchQueue.global().asyncAfter(deadline: .now() + $0, execute: $1)
        }
    ) -> RewardAdViewController {
        let rewardAdViewController = RewardAdViewController(loader: ExponentialBackoffDecorator(loader, asyncAfter: asyncAfter)
, rewardChanceCount: rewardChanceCount, hostViewController: hostViewController)
        
        return rewardAdViewController
    }
}

extension ExponentialBackoffDecorator: RewardAdLoader where T == RewardAdLoader {
    func load(completion: @escaping (RewardAdLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.handle(result: result, completion: completion, onRetry: { [weak self] in
                self?.load(completion: completion)
            })
        }
    }
}
