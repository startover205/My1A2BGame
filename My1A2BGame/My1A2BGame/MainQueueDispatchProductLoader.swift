//
//  MainQueueDispatchProductLoader.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/12/25.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import StoreKit

public final class MainQueueDispatchProductLoader: IAPProductLoader {
    public override func load(completion: @escaping ([SKProduct]) -> Void) {
        super.load { result in
            if Thread.isMainThread {
                completion(result)
            } else {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}
