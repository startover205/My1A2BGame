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
        let product = aProduct()
        let purchasedTransaction = makePurchasedTransaction(with: product)
        sut.onPurchaseProduct = { _ in }

        sut.paymentQueue(paymentQueue, updatedTransactions: [cancelledTransaction, purchasedTransaction])

        XCTAssertEqual(delegate.receivedMessages, [.didPurchaseIAP(productIdentifier: aProduct().productIdentifier)])
    }

    func test_handleTransaction_messagesDelegatePurchasedProduct_onSuccessfullyPurchasedTransaction() throws {
        let (sut, delegate, paymentQueue) = makeSUT()
        let product = aProduct()
        try createLocalTestSession()
        
        simulateBuying(product, observer: sut, paymentQueue: paymentQueue)

        XCTAssertEqual(delegate.receivedMessages, [.didPurchaseIAP(productIdentifier: product.productIdentifier)])
    }

    func test_restoreCompletedTransactions_doesNotMessageDelegateOnRestorationFailedWithError() throws {
        let (sut, delegate, paymentQueue) = makeSUT()
        let product = aProduct()
        try createLocalTestSession()
        
        simulateBuying(product, observer: sut, paymentQueue: paymentQueue)
        sut.simulateRestoreCompletedTransactionFailedWithError(on: paymentQueue)

        XCTAssertEqual(delegate.receivedMessages, [.didPurchaseIAP(productIdentifier: product.productIdentifier)])
    }

    func test_restoreCompletedTransactions_messagesDelegateOnSuccessfulRestoration() throws {
        let (sut, delegate, paymentQueue) = makeSUT()
        let product = aProduct()
        try createLocalTestSession()
        
        simulateBuying(product, observer: sut, paymentQueue: paymentQueue)
        simulateRestoringCompletedTransactions(observer: sut, paymentQueue: paymentQueue)

        XCTAssertEqual(delegate.receivedMessages, [.didPurchaseIAP(productIdentifier: product.productIdentifier), .didRestoreIAP])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (IAPTransactionObserver, IAPTransactionObserverDelegateSpy, SKPaymentQueue) {
        let paymentQueue = SKPaymentQueue()
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
}

private extension IAPTransactionObserver {
    func simulateRestoreCompletedTransactionFailedWithError(on queue: SKPaymentQueue) {
        paymentQueue(queue, restoreCompletedTransactionsFailedWithError: anyNSError())
    }
}
