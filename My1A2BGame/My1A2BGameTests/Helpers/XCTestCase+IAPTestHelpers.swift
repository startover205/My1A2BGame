//
//  XCTestCase+IAPTestHelpers.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/11/18.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import StoreKitTest

extension XCTestCase {
    @available(iOS 14.0, *)
    func simulateSuccessfullyPurchasedTransaction(product: SKProduct) throws {
        let session = try SKTestSession(configurationFileNamed: "NonConsumable")
        session.disableDialogs = true
        session.clearTransactions()
        
        SKPaymentQueue.default().add(SKPayment(product: product))
        
        let exp = expectation(description: "wait for request")
        exp.isInverted = true
        wait(for: [exp], timeout: 0.5)
    }

    func simulateSuccessfulRestoration() {
        SKPaymentQueue.default().restoreCompletedTransactions()
        
        let exp = expectation(description: "wait for request")
        exp.isInverted = true
        wait(for: [exp], timeout: 0.5)
    }

    func aProduct() -> SKProduct {
        let product = SKProduct()
        product.setValue("remove_bottom_ad", forKey: "productIdentifier")
        return product
    }
}
