//
//  UserDefaultsPurchaseStore.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/12/22.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import Foundation

public struct UserDefaultsPurchaseRecordStore {
    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    public func hasPurchaseProduct(productIdentifier: String) -> Bool {
        userDefaults.bool(forKey: productIdentifier)
    }
    
    public func insertPurchaseRecord(productIdentifier: String) {
        userDefaults.set(true, forKey: productIdentifier)
    }
}
