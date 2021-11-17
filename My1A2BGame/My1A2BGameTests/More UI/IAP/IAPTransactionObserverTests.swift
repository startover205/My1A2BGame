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
    
    func test_handleTransaction_doesNotMessageDelegateOnFailedTransaction() throws {
        let (_, delegate) = makeSUT()
        
        try simulateFailedTransaction()
        
        XCTAssertTrue(delegate.receivedMessages.isEmpty)
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
        let session = try SKTestSession(configurationFileNamed: "NonConsumable")
        session.disableDialogs = true
        session.clearTransactions()
        session.failTransactionsEnabled = true
        
        SKPaymentQueue.default().add(SKPayment(product: aProduct()))
        
        let exp = expectation(description: "wait for request")
        exp.isInverted = true
        wait(for: [exp], timeout: 3.0)
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
    
    private func aProduct() -> SKProduct {
        let product = SKProduct()
        product.setValue("remove_bottom_ad", forKey: "productIdentifier")
        return product
    }
}
