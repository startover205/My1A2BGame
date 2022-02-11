//
//  RewardAdLoader.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/9/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import Foundation

public protocol RewardAdLoader {
    typealias Result = Swift.Result<RewardAd, Error>
    
    func load(completion: @escaping (Result) -> Void)
}
