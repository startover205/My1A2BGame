//
//  ReplenishChanceDelegate.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/9/3.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import Foundation

public protocol ReplenishChanceDelegate {
    func replenishChance(completion: @escaping (Int) -> Void)
}
