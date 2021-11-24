//
//  SKProduct+LocalPrice.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/11/24.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import StoreKit

extension SKProduct {
    var localPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
