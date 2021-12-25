//
//  MainQueueDispatchProductLoader.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/12/25.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import StoreKit

public final class MainQueueDispatchProductLoader: IAPProductLoader {
    private static let key = DispatchSpecificKey<UInt8>()
    private static let value = UInt8.max
    
    public override init(makeRequest: @escaping (Set<String>) -> SKProductsRequest, getProductIDs: @escaping () -> Set<String>) {
        super.init(makeRequest: makeRequest, getProductIDs: getProductIDs)
        
        DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
    }
    
    private func isMainQueue() -> Bool {
        DispatchQueue.getSpecific(key: Self.key) == Self.value
    }
    
    public override func load(completion: @escaping ([SKProduct]) -> Void) {
        super.load { result in
            if self.isMainQueue() {
                completion(result)
            } else {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}
