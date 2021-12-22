//
//  UserDefaultsPurchaseStore.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/12/22.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import Foundation

struct UserDefaultsPurchaseRecordStore {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    func hasPurchaseProduct(productIdentifier: String) -> Bool {
        userDefaults.bool(forKey: productIdentifier)
    }
    
    func insertPurchaseRecord(productIdentifier: String) {
        userDefaults.set(true, forKey: productIdentifier)
    }
}
