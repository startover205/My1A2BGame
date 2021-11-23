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

    func simulateFailedTransaction(_ error: SKError.Code = .unknown) throws {
        let session = try createLocalTestSession()
        session.failTransactionsEnabled = true
        session.failureError = .unknown
        
        SKPaymentQueue.default().add(SKPayment(product: aProduct()))
        
        let exp = expectation(description: "wait for request")
        exp.isInverted = true
        wait(for: [exp], timeout: 0.5)
    }

    func simulateSuccessfullyPurchasedTransaction(product: SKProduct) throws {
        try createLocalTestSession()
        
        SKPaymentQueue.default().add(SKPayment(product: product))
        
        let exp = expectation(description: "wait for request")
        exp.isInverted = true
        wait(for: [exp], timeout: 0.5)
    }

    func simulateSuccessfulRestoration() {
        SKPaymentQueue.default().restoreCompletedTransactions()
        
        let exp = expectation(description: "wait for request")
        exp.isInverted = true
        wait(for: [exp], timeout: 1.5)
    }

    func aProduct() -> SKProduct {
        let product = SKProduct()
        product.setValue("remove_bottom_ad", forKey: "productIdentifier")
        return product
    }
}
