//
//  IAPTransactionObserverTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/11/17.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
@testable import My1A2BGame

class IAPTransactionObserverTests: XCTestCase {
    
    func test_init_doesNotMessageDelegate() {
        let (_, delegate) = makeSUT()
        
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
