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
        let (_, delegate) = makeSUT()
        
        XCTAssertTrue(delegate.receivedMessages.isEmpty)
    }
    
    func test_handleTransaction_doesNotMessageDelegate_OnFailedTransaction() throws {
        let (_, delegate) = makeSUT()
        
        try simulateFailedTransaction()
        
        XCTAssertTrue(delegate.receivedMessages.isEmpty)
    }
    
    func test_handleTransaction_stillHandlesOtherTransactionsAfterCancelledTransaction() throws {
        let (sut, delegate) = makeSUT()
        let failedTransaction = makeFailedTransaction(with: .paymentCancelled)
        let product = aProduct()
        let purchasedTransaction = makePurchasedTransaction(with: product)
        sut.onPurchaseProduct = { _ in }
        
        sut.paymentQueue(SKPaymentQueue(), updatedTransactions: [failedTransaction, purchasedTransaction])
        
        XCTAssertEqual(delegate.receivedMessages, [.didPurchaseIAP(productIdentifier: aProduct().productIdentifier)])
    }
    
    func test_handleTransaction_messagesDelegatePurchasedProduct_onSuccessfullyPurchasedTransaction() throws {
        let (sut, delegate) = makeSUT()
        let product = aProduct()
        sut.onPurchaseProduct = { _ in }

        try simulateSuccessfullyPurchasedTransaction(product: product)

        XCTAssertEqual(delegate.receivedMessages, [.didPurchaseIAP(productIdentifier: product.productIdentifier)])
    }
    
    func test_restoreCompletedTransactions_doesNotMessageDelegateOnRestorationFailedWithError() throws {
        let (sut, delegate) = makeSUT()
        let product = aProduct()
        sut.onPurchaseProduct = { _ in }

        try simulateSuccessfullyPurchasedTransaction(product: product)
        sut.simulateRestoreCompletedTransactionFailedWithError()

        XCTAssertEqual(delegate.receivedMessages, [.didPurchaseIAP(productIdentifier: product.productIdentifier)])
    }
    
    func test_restoreCompletedTransactions_messagesDelegateOnSuccessfulRestoration() throws {
        let (sut, delegate) = makeSUT()
        let product = aProduct()
        sut.onPurchaseProduct = { _ in }

        try simulateSuccessfullyPurchasedTransaction(product: product)
        simulateSuccessfulRestoration()

        XCTAssertEqual(delegate.receivedMessages, [.didPurchaseIAP(productIdentifier: product.productIdentifier), .didRestoreIAP])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (IAPTransactionObserver, IAPTransactionObserverDelegateSpy) {
        let delegate = IAPTransactionObserverDelegateSpy()
        let sut = IAPTransactionObserver()
        sut.delegate = delegate
        
        SKPaymentQueue.default().add(sut)
        
        trackForMemoryLeaks(delegate, file: file, line: line)
        
        return (sut, delegate)
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
    func simulateRestoreCompletedTransactionFailedWithError() {
        paymentQueue(SKPaymentQueue(), restoreCompletedTransactionsFailedWithError: anyNSError())
    }
}
