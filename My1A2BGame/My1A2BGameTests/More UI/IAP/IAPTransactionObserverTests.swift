//
//  IAPTransactionObserverTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/11/17.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import StoreKitTest
@testable import My1A2BGame

@available(iOS 14.0, *)
class IAPTransactionObserverTests: XCTestCase {

    func test_handleTransaction_stillHandlesOtherTransactionsAfterCancelledTransaction() {
        let (sut, paymentQueue) = makeSUT()
        let cancelledTransaction = makeFailedTransaction(with: .paymentCancelled)
        let purchasedTransaction = makePurchasedTransaction(with: oneValidProduct())
        
        let exp = expectation(description: "wait for purchased transaction to be handled")
        sut.onPurchaseProduct = { _ in
            exp.fulfill()
        }
        sut.paymentQueue(paymentQueue, updatedTransactions: [cancelledTransaction, purchasedTransaction])
        
        wait(for: [exp], timeout: 0.1)
    }

    func test_handleTransaction_notifiesHandlerPurchasedProduct_onSuccessfullyPurchasedTransaction() throws {
        let (sut, paymentQueue) = makeSUT()
        let product = oneValidProduct()
        try createLocalTestSession()
        let exp = expectation(description: "wait for transaction")
        
        sut.onPurchaseProduct = { productIdentifier in
            XCTAssertEqual(productIdentifier, product.productIdentifier)
            
            exp.fulfill()
        }
        paymentQueue.add(SKPayment(product: product))
        
        wait(for: [exp], timeout: 20.0)
    }

    func test_handleTransaction_doesNotNotifyHandlerPurchasedProductTwice_onDuplicatedPurchasedTransactions() throws {
        let (sut, paymentQueue) = makeSUT()
        let product = oneValidProduct()
        let duplicatedPurchasedTransaction = makePurchasedTransaction(with: product, transactionIdentifier: "a transaction ID")
        let exp = expectation(description: "wait for transaction")
        
        sut.onPurchaseProduct = { _ in
            exp.fulfill()
        }
        sut.paymentQueue(paymentQueue, updatedTransactions: [duplicatedPurchasedTransaction, duplicatedPurchasedTransaction])
        
        wait(for: [exp], timeout: 5.0)
    }
    
    func test_handleTransaction_doesNotFinishesTransactionWithNoHandler_onPurchasedTransaction() throws {
        let (sut, paymentQueue) = makeSUT()
        let product = oneValidProduct()
        
        sut.onPurchaseProduct = nil
        sut.paymentQueue(paymentQueue, updatedTransactions: [makePurchasedTransaction(with: product)])
        
        XCTAssertNil(paymentQueue.finishedTransaction)
    }
    
    func test_handleTransaction_finishesTransactionAfterNotifyingHandler_onPurchasedTransaction() throws {
        let (sut, paymentQueue) = makeSUT()
        let product = oneValidProduct()
        try createLocalTestSession()
        let exp = expectation(description: "wait for transaction")
        
        sut.onPurchaseProduct = { productIdentifier in
            exp.fulfill()
        }
        paymentQueue.add(SKPayment(product: product))

        wait(for: [exp], timeout: 20.0)
        
        XCTAssertEqual(paymentQueue.finishedTransaction?.payment.productIdentifier, product.productIdentifier)
    }
    
    func test_handleTransaction_doesNotNotifyHandler_onFailedTransactionWithCancellation() throws {
        let (sut, paymentQueue) = makeSUT()
        var handlerCallCount = 0
        
        sut.onTransactionError = { _ in
            handlerCallCount += 1
        }
        sut.paymentQueue(paymentQueue, updatedTransactions: [makeFailedTransaction(with: .paymentCancelled)])
        
        XCTAssertEqual(handlerCallCount, 0)
    }
    
    func test_handleTransaction_notifiesHandlerError_onFailedTransaction() throws {
        let (sut, paymentQueue) = makeSUT()
        let failureError = SKError(.invalidOfferIdentifier)
        let session = try createLocalTestSession()
        session.failTransactionsEnabled = true
        session.failureError = failureError.code
        let exp = expectation(description: "wait for transaction")
        
        sut.onTransactionError = { error in
            let error = error! as NSError
            let failureError = failureError as NSError
            XCTAssertEqual(error.domain, failureError.domain)
            XCTAssertEqual(error.code, failureError.code)
            
            exp.fulfill()
        }
        paymentQueue.add(SKPayment(product: oneValidProduct()))
        
        wait(for: [exp], timeout: 20.0)
    }
    
    func test_handleTransaction_doesNotFinishesTransactionWithNoHandler_onFailedTransaction() throws {
        let (sut, paymentQueue) = makeSUT()
        
        sut.onTransactionError = nil
        sut.paymentQueue(paymentQueue, updatedTransactions: [makeFailedTransaction(with: .clientInvalid)])
        
        XCTAssertNil(paymentQueue.finishedTransaction)
    }
    
    func test_handleTransaction_finishesTransactionAfterNotifyingHandler_onFailedTransaction() throws {
        let (sut, paymentQueue) = makeSUT()
        let product = oneValidProduct()
        let session = try createLocalTestSession()
        session.failTransactionsEnabled = true
        let exp = expectation(description: "wait for transaction")
        
        sut.onTransactionError = { _ in
            exp.fulfill()
        }
        paymentQueue.add(SKPayment(product: product))

        wait(for: [exp], timeout: 20.0)
        
        XCTAssertEqual(paymentQueue.finishedTransaction?.payment.productIdentifier, product.productIdentifier)
    }
    
    func test_handleTransaction_notifiesHandlerRestoredProduct_onSuccessfullyRestoredTransaction() throws {
        let (sut, paymentQueue) = makeSUT()
        let product = oneValidProduct()
        try createLocalTestSession()
        
        simulateBuying(product, observer: sut, paymentQueue: paymentQueue)
        
        waitForTransactionFinished()

        let exp = expectation(description: "wait for transaction")
        sut.onRestoreProduct = { productIdentifier in
            XCTAssertEqual(productIdentifier, product.productIdentifier)
            
            exp.fulfill()
        }
        paymentQueue.restoreCompletedTransactions()
        
        wait(for: [exp], timeout: 20.0)
    }
    
    func test_handleTransaction_doesNotFinishTransactionWithNoHandler_onSuccessfullyRestoredTransaction() throws {
        let (sut, paymentQueue) = makeSUT()
        
        sut.onRestoreProduct = nil
        sut.paymentQueue(paymentQueue, updatedTransactions: [makeRestoredTransaction()])
        
        XCTAssertNil(paymentQueue.finishedTransaction)
    }
    
    func test_handleTransaction_finishesTransactionAfterNotifyingHandler_onSuccessfullyRestoredTransaction() throws {
        let (sut, paymentQueue) = makeSUT()
        let product = oneValidProduct()
        try createLocalTestSession()
        
        simulateBuying(product, observer: sut, paymentQueue: paymentQueue)
        
        waitForTransactionFinished()

        let exp = expectation(description: "wait for transaction")
        sut.onRestoreProduct = { _ in
            exp.fulfill()
        }
        paymentQueue.restoreCompletedTransactions()
        
        wait(for: [exp], timeout: 20.0)
        
        XCTAssertEqual(paymentQueue.finishedTransaction?.payment.productIdentifier, product.productIdentifier)
    }
    
    func test_restoreCompletedTransactionsFailedWithError_notifiesHandlerError() {
        let (sut, paymentQueue) = makeSUT()
        let restorationError = anyNSError()
        let exp = expectation(description: "wait for transaction")

        sut.onRestorationFinishedWithError = { error in
            XCTAssertEqual(error as NSError, restorationError as NSError)
            
            exp.fulfill()
        }
        sut.paymentQueue(paymentQueue, restoreCompletedTransactionsFailedWithError: restorationError)
        
        wait(for: [exp], timeout: 5.0)
    }
    
    func test_restoreCompletedTransactionsFinished_notifiesHandlerWhenThereIsNoRestorableContent() throws {
        let (sut, paymentQueue) = makeSUT()
        try createLocalTestSession()
        let exp = expectation(description: "wait for transaction")

        sut.onRestorationFinished = { hasRestorableContent in
            XCTAssertFalse(hasRestorableContent)
            
            exp.fulfill()
        }
        paymentQueue.restoreCompletedTransactions()
        
        wait(for: [exp], timeout: 20.0)
    }
    
    func test_restoreCompletedTransactionsFinished_notifiesHandlerWhenThereIsRestorableContent() throws {
        let (sut, paymentQueue) = makeSUT()
        try createLocalTestSession()
        
        simulateBuying(oneValidProduct(), observer: sut, paymentQueue: paymentQueue)
        
        waitForTransactionFinished()
        
        let exp = expectation(description: "wait for transaction")
        sut.onRestorationFinished = { hasRestorableContent in
            XCTAssertTrue(hasRestorableContent)
            
            exp.fulfill()
        }
        paymentQueue.restoreCompletedTransactions()
        
        wait(for: [exp], timeout: 20.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (IAPTransactionObserver, SKPaymentQueueSpy) {
        let paymentQueue = SKPaymentQueueSpy()
        let sut = IAPTransactionObserver()
        
        paymentQueue.add(sut)
        
        return (sut, paymentQueue)
    }
    
    private func waitForTransactionFinished() {
        let exp = expectation(description: "wait for transaction to be finished")
        exp.isInverted = true
        wait(for: [exp], timeout: 0.1)
    }
    
    private final class SKPaymentQueueSpy: SKPaymentQueue {
        private(set) var finishedTransaction: SKPaymentTransaction?
        
        override func finishTransaction(_ transaction: SKPaymentTransaction) {
            finishedTransaction = transaction
            
            super.finishTransaction(transaction)
        }
    }
}
