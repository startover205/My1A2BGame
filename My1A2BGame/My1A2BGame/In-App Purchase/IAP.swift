//
//  IAP.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/4/15.
//  Copyright © 2019 Ming-Ta Yang. All rights reserved.
//

import Foundation
import UIKit

enum IAP: String {
    case remove_bottom_ad
    static weak var bottomAdHightConstraint: NSLayoutConstraint?
    
    static func didPurchase(product: IAP, userDefaults: UserDefaults) {
        switch product {
        case .remove_bottom_ad:
            userDefaults.set(true, forKey: UserDefaults.Key.remove_bottom_ad)
            bottomAdHightConstraint?.firstItem?.superview?.layoutIfNeeded()
            UIView.animate(withDuration: 0.4) {
                bottomAdHightConstraint?.constant = 0
                bottomAdHightConstraint?.firstItem?.superview?.layoutIfNeeded()
            }
        }
    }
    
    static func getAvailableProductsId(userDefaults: UserDefaults) -> [String] {
        var productIdList = [String]()
        if !userDefaults.bool(forKey: UserDefaults.Key.remove_bottom_ad){
            productIdList.append(IAP.remove_bottom_ad.rawValue)
        }
        return productIdList
    }
}
