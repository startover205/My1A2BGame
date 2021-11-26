//
//  XCTestCase+IAPTestHelpers.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/11/18.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import StoreKitTest

@available(iOS 14.0, *)
extension XCTestCase {
    @discardableResult
    func createLocalTestSession(_ configurationFileNamed: String = "NonConsumable") throws -> SKTestSession {
        let session = try SKTestSession(configurationFileNamed: configurationFileNamed)
        session.disableDialogs = true
        session.clearTransactions()
        
        addTeardownBlock {
            session.clearTransactions()
        }
        
        return session
    }

    func oneValidProduct() -> SKProduct {
        let product = SKProduct()
        product.setValue("a product name", forKey: "localizedTitle")
        product.setValue("remove_bottom_ad", forKey: "productIdentifier")
        product.setValue(0.99, forKey: "price")
        product.setValue(Locale(identifier: "en_US_POSIX"), forKey: "priceLocale")

        return product
    }
    
    func makeProduct(identifier: String = "product identifier", name: String = "product name", locale: Locale = Locale(identifier: "en_US_POSIX"), price: NSDecimalNumber = 0.99) -> SKProduct {
        let product = SKProduct()
        product.setValue(name, forKey: "localizedTitle")
        product.setValue(identifier, forKey: "productIdentifier")
        product.setValue(price, forKey: "price")
        product.setValue(locale, forKey: "priceLocale")
        
        return product
    }
}
