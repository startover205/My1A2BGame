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
    
    func test_handleTransaction_messagesDelegatePurchasedProduct_onSuccessfullyPurchasedTransaction() throws {
        let (_, delegate) = makeSUT()
        let product = aProduct()
        
        try simulateSuccessfullyPurchasedTransaction(product: product)
        
        XCTAssertEqual(delegate.receivedMessages, [.didPurchaseIAP(productIdentifier: product.productIdentifier)])
    }
    
    func test_restoreCompletedTransactions_doesNotMessageDelegateOnRestorationFailedWithError() throws {
        let (sut, delegate) = makeSUT()
        let product = aProduct()
        
        try simulateSuccessfullyPurchasedTransaction(product: product)
        sut.simulateRestoreCompletedTransactionFailedWithError()
        
        XCTAssertEqual(delegate.receivedMessages, [.didPurchaseIAP(productIdentifier: product.productIdentifier)])
    }
    
    func test_restoreCompletedTransactions_messagesDelegateOnSuccessfulRestoration() throws {
        let (_, delegate) = makeSUT()
        let product = aProduct()
        
        try simulateSuccessfullyPurchasedTransaction(product: product)
        simulateSuccessfulRestoration()
        
        XCTAssertEqual(delegate.receivedMessages, [.didPurchaseIAP(productIdentifier: product.productIdentifier), .didRestoreIAP])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (IAPTransactionObserver, IAPTransactionObserverDelegateSpy) {
        let delegate = IAPTransactionObserverDelegateSpy()
        let sut = IAPTransactionObserver.shared
        sut.delegate = delegate
        
        trackForMemoryLeaks(delegate, file: file, line: line)
        
        return (sut, delegate)
    }
    
    private func simulateFailedTransaction() throws {
        let session = try createLocalTestSession()
        session.failTransactionsEnabled = true
        
        SKPaymentQueue.default().add(SKPayment(product: aProduct()))
        
        let exp = expectation(description: "wait for request")
        exp.isInverted = true
        wait(for: [exp], timeout: 0.5)
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
