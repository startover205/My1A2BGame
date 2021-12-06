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
    
    func test_init_doesNotMessageDelegate() {
        let (_, delegate, _) = makeSUT()
        
        XCTAssertTrue(delegate.receivedMessages.isEmpty)
    }
    
    func test_handleTransaction_doesNotMessageDelegate_OnFailedTransaction() {
        let (sut, delegate, paymentQueue) = makeSUT()
        
        sut.simulateFailedTransaction(with: .unknown, from: paymentQueue)

        XCTAssertTrue(delegate.receivedMessages.isEmpty)
    }

    func test_handleTransaction_stillHandlesOtherTransactionsAfterCancelledTransaction() {
        let (sut, delegate, paymentQueue) = makeSUT()
        let cancelledTransaction = makeFailedTransaction(with: .paymentCancelled)
        let product = oneValidProduct()
        let purchasedTransaction = makePurchasedTransaction(with: product)
        sut.onPurchaseProduct = { _ in }

        sut.paymentQueue(paymentQueue, updatedTransactions: [cancelledTransaction, purchasedTransaction])

        XCTAssertEqual(delegate.receivedMessages, [.didPurchaseIAP(productIdentifier: oneValidProduct().productIdentifier)])
    }

    func test_handleTransaction_messagesDelegatePurchasedProduct_onSuccessfullyPurchasedTransaction() throws {
        let (sut, delegate, paymentQueue) = makeSUT()
        let product = oneValidProduct()
        try createLocalTestSession()
        
        simulateBuying(product, observer: sut, paymentQueue: paymentQueue)

        XCTAssertEqual(delegate.receivedMessages, [.didPurchaseIAP(productIdentifier: product.productIdentifier)])
    }
    
    func test_handleTransaction_notifiesHandlerPurchasedProduct_onSuccessfullyPurchasedTransaction() throws {
        let (sut, _, paymentQueue) = makeSUT()
        let product = oneValidProduct()
        try createLocalTestSession()
        let exp = expectation(description: "wait for transaction")
        
        sut.onPurchaseProduct = { productIdentifier in
            XCTAssertEqual(productIdentifier, product.productIdentifier)
            
            exp.fulfill()
        }
        paymentQueue.add(SKPayment(product: product))
        
        wait(for: [exp], timeout: 5.0)
    }

    func test_handleTransaction_doesNotNotifyHandlerPurchasedProductTwice_onDuplicatedPurchasedTransactions() throws {
        let (sut, _, paymentQueue) = makeSUT()
        let product = oneValidProduct()
        let duplicatedTransaction = makePurchasedTransaction(with: product, transactionIdentifier: "a transaction ID")
        let exp = expectation(description: "wait for transaction")
        
        sut.onPurchaseProduct = { productIdentifier in
            exp.fulfill()
        }
        sut.paymentQueue(paymentQueue, updatedTransactions: [duplicatedTransaction, duplicatedTransaction])
        
        wait(for: [exp], timeout: 5.0)
    }
    
    func test_handleTransaction_doesNotFinishesTransactionWithNoHandler_onPurchasedTransaction() throws {
        let (sut, _, paymentQueue) = makeSUT()
        let product = oneValidProduct()
        
        sut.onPurchaseProduct = nil
        sut.paymentQueue(paymentQueue, updatedTransactions: [makePurchasedTransaction(with: product)])
        
        XCTAssertNil(paymentQueue.finishedTransaction)
    }
    
    func test_handleTransaction_finishesTransactionAfterNotifyingHandler_onPurchasedTransaction() throws {
        let (sut, _, paymentQueue) = makeSUT()
        let product = oneValidProduct()
        try createLocalTestSession()
        let exp = expectation(description: "wait for transaction")
        
        sut.onPurchaseProduct = { productIdentifier in
            exp.fulfill()
        }
        paymentQueue.add(SKPayment(product: product))
        XCTAssertEqual(paymentQueue.transactions.count, 1)

        wait(for: [exp], timeout: 5.0)
        
        XCTAssertEqual(paymentQueue.finishedTransaction?.payment.productIdentifier, product.productIdentifier)
    }
    
    func test_handleTransaction_doesNotNotifyHandler_onFailedTransactionWithCancellation() throws {
        let (sut, _, paymentQueue) = makeSUT()
        var handlerCallCount = 0
        
        sut.onTransactionError = { _ in
            handlerCallCount += 1
        }
        sut.paymentQueue(paymentQueue, updatedTransactions: [makeFailedTransaction(with: .paymentCancelled)])
        
        XCTAssertEqual(handlerCallCount, 0)
    }
    
    func test_handleTransaction_notifiesHandlerError_onFailedTransaction() throws {
        let (sut, _, paymentQueue) = makeSUT()
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
        
        wait(for: [exp], timeout: 5.0)
    }
    
    func test_handleTransaction_doesNotFinishesTransactionWithNoHandler_onFailedTransaction() throws {
        let (sut, _, paymentQueue) = makeSUT()
        
        sut.onTransactionError = nil
        sut.paymentQueue(paymentQueue, updatedTransactions: [makeFailedTransaction(with: .clientInvalid)])
        
        XCTAssertNil(paymentQueue.finishedTransaction)
    }
    
    func test_handleTransaction_finishesTransactionAfterNotifyingHandler_onFailedTransaction() throws {
        let (sut, _, paymentQueue) = makeSUT()
        let product = oneValidProduct()
        let session = try createLocalTestSession()
        session.failTransactionsEnabled = true
        let exp = expectation(description: "wait for transaction")
        
        sut.onTransactionError = { productIdentifier in
            exp.fulfill()
        }
        paymentQueue.add(SKPayment(product: product))
        XCTAssertEqual(paymentQueue.transactions.count, 1)

        wait(for: [exp], timeout: 5.0)
        
        XCTAssertEqual(paymentQueue.finishedTransaction?.payment.productIdentifier, product.productIdentifier)
    }
    
    func test_handleTransaction_notifiesHandlerRestoredProduct_onSuccessfullyRestoredTransaction() throws {
        let (sut, _, paymentQueue) = makeSUT()
        let product = oneValidProduct()
        try createLocalTestSession()
        let exp = expectation(description: "wait for transaction")
        
        simulateBuying(product, observer: sut, paymentQueue: paymentQueue)
        sut.onRestoreProduct = { productIdentifier in
            XCTAssertEqual(productIdentifier, product.productIdentifier)
            
            exp.fulfill()
        }
        paymentQueue.restoreCompletedTransactions()
        
        wait(for: [exp], timeout: 5.0)
    }
    
    func test_handleTransaction_doesNotFinishTransactionWithNoHandler_onSuccessfullyRestoredTransaction() throws {
        let (sut, _, paymentQueue) = makeSUT()
        
        sut.onRestoreProduct = nil
        sut.paymentQueue(paymentQueue, updatedTransactions: [makeRestoredTransaction()])
        
        XCTAssertNil(paymentQueue.finishedTransaction)
    }
    
    func test_handleTransaction_finishesTransactionAfterNotifyingHandler_onSuccessfullyRestoredTransaction() throws {
        let (sut, _, paymentQueue) = makeSUT()
        let product = oneValidProduct()
        try createLocalTestSession()
        let exp = expectation(description: "wait for transaction")
        
        simulateBuying(product, observer: sut, paymentQueue: paymentQueue)
        sut.onRestoreProduct = { _ in
            exp.fulfill()
        }
        paymentQueue.restoreCompletedTransactions()
        
        wait(for: [exp], timeout: 5.0)
        
        XCTAssertEqual(paymentQueue.finishedTransaction?.payment.productIdentifier, product.productIdentifier)
    }
    
    func test_restoreCompletedTransactionsFailedWithError_notifiesHandlerError() {
        let (sut, _, paymentQueue) = makeSUT()
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
        let (sut, _, paymentQueue) = makeSUT()
        try createLocalTestSession()
        let exp = expectation(description: "wait for transaction")

        sut.onRestorationFinished = { hasRestorableContent in
            XCTAssertFalse(hasRestorableContent)
            
            exp.fulfill()
        }
        paymentQueue.restoreCompletedTransactions()
        
        wait(for: [exp], timeout: 5.0)
    }
    
    func test_restoreCompletedTransactionsFinished_notifiesHandlerWhenThereIsRestorableContent() throws {
        let (sut, _, paymentQueue) = makeSUT()
        try createLocalTestSession()
        
        simulateBuying(oneValidProduct(), observer: sut, paymentQueue: paymentQueue)
        
        let exp = expectation(description: "wait for transaction")
        sut.onRestorationFinished = { hasRestorableContent in
            XCTAssertTrue(hasRestorableContent)
            
            exp.fulfill()
        }
        paymentQueue.restoreCompletedTransactions()
        
        wait(for: [exp], timeout: 5.0)
    }
    
    func test_restoreCompletedTransactions_doesNotMessageDelegateOnRestorationFailedWithError() throws {
        let (sut, delegate, paymentQueue) = makeSUT()
        let product = oneValidProduct()
        try createLocalTestSession()
        
        simulateBuying(product, observer: sut, paymentQueue: paymentQueue)
        sut.simulateRestoreCompletedTransactionFailedWithError(on: paymentQueue)

        XCTAssertEqual(delegate.receivedMessages, [.didPurchaseIAP(productIdentifier: product.productIdentifier)])
    }

    func test_restoreCompletedTransactions_messagesDelegateOnSuccessfulRestoration() throws {
        let (sut, delegate, paymentQueue) = makeSUT()
        let product = oneValidProduct()
        try createLocalTestSession()
        
        simulateBuying(product, observer: sut, paymentQueue: paymentQueue)
        simulateRestoringCompletedTransactions(observer: sut, paymentQueue: paymentQueue)

        XCTAssertEqual(delegate.receivedMessages, [.didPurchaseIAP(productIdentifier: product.productIdentifier), .didRestoreIAP])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (IAPTransactionObserver, IAPTransactionObserverDelegateSpy, SKPaymentQueueSpy) {
        let paymentQueue = SKPaymentQueueSpy()
        let delegate = IAPTransactionObserverDelegateSpy()
        let sut = IAPTransactionObserver()
        sut.delegate = delegate
        
        paymentQueue.add(sut)
        
        trackForMemoryLeaks(delegate, file: file, line: line)
        
        return (sut, delegate, paymentQueue)
    }
    
    private final class IAPTransactionObserverDelegateSpy: IAPTransactionObserverDelegate {
        enum Message: Equatable {
            case didPurchaseIAP(productIdentifier: String)
            case didRestoreIAP
        }
        
        private(set) var receivedMessages = [Message]()
        
        func didPuarchaseIAP(productIdenifer: String) {
            receivedMessages.append(.didPurchaseIAP(productIdentifier: productIdenifer))
        }
        func didRestoreIAP() {
            receivedMessages.append(.didRestoreIAP)
        }
    }
    
    private final class SKPaymentQueueSpy: SKPaymentQueue {
        private(set) var finishedTransaction: SKPaymentTransaction?
        
        override func finishTransaction(_ transaction: SKPaymentTransaction) {
            finishedTransaction = transaction
            
            super.finishTransaction(transaction)
        }
    }
}

private extension IAPTransactionObserver {
    func simulateRestoreCompletedTransactionFailedWithError(on queue: SKPaymentQueue) {
        paymentQueue(queue, restoreCompletedTransactionsFailedWithError: anyNSError())
    }
}
