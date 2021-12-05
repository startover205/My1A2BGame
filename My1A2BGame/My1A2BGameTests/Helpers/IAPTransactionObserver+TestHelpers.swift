//
//  IAPTransactionObserver+TestHelpers.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/11/26.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import StoreKit
@testable import My1A2BGame

extension IAPTransactionObserver {
    func simulateFailedTransactionWithCancellation(from queue: SKPaymentQueue) {
        paymentQueue(queue, updatedTransactions: [makeFailedTransaction(with: .paymentCancelled)])
    }
    
    func simulateFailedTransaction(with error: SKError.Code, from queue: SKPaymentQueue) {
        paymentQueue(queue, updatedTransactions: [makeFailedTransaction(with: error)])
    }
    
    func simulateRestoreCompletedTransactionFailed(with error: Error, from queue: SKPaymentQueue) {
        paymentQueue(queue, restoreCompletedTransactionsFailedWithError: error)
    }
}

extension XCTestCase {
    func simulateRestoringCompletedTransactions(observer: IAPTransactionObserver, paymentQueue: SKPaymentQueue) {
        let exp = expectation(description: "wait for transaction")
        
        let originalHandler = observer.onRestorationFinished
        observer.onRestorationFinished = {
            originalHandler?($0)

            exp.fulfill()
        }
        paymentQueue.restoreCompletedTransactions()
        wait(for: [exp], timeout: 10.0)
    }
    
    func simulateBuying(_ product: SKProduct, observer: IAPTransactionObserver, paymentQueue: SKPaymentQueue) {
        let exp = expectation(description: "wait for transaction")
        
        let originalHandler = observer.onPurchaseProduct
        observer.onPurchaseProduct = {
            originalHandler?($0)
            
            exp.fulfill()
        }
        paymentQueue.add(SKPayment(product: product))
        wait(for: [exp], timeout: 10.0)
    }
}
