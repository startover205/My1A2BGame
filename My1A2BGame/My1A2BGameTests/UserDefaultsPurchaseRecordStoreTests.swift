//
//  UserDefaultsPurchaseRecordStoreTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/12/22.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame

class UserDefaultsPurchaseRecordStoreTests: XCTestCase {

    func test_init_doesNotSendMessageToUserDefaults() {
        let (_, userDefaults) = makeSUT()
        
        XCTAssertTrue(userDefaults.receivedMessages.isEmpty)
    }
    
    func test_hasPurchaseProduct_requestsPurchaseRecordRetrieval() {
        let (sut, userDefaults) = makeSUT()
        let productIdentifier = "an identifier"
        
        _ = sut.hasPurchaseProduct(productIdentifier: productIdentifier)
        
        XCTAssertEqual(userDefaults.receivedMessages, [.retrieveValue(forKey: productIdentifier)])
    }
    
    func test_hasPurchaseProduct_deliversFalseForEmptyStore() {
        let (sut, userDefaults) = makeSUT()
        let productIdentifier = "an identifier"
        userDefaults.completeRetrieval(with: nil, for: productIdentifier)
        
        let result = sut.hasPurchaseProduct(productIdentifier: productIdentifier)
        
        XCTAssertFalse(result)
    }
    
    func test_hasPurchaseProduct_deliversFalseForInvalidPurchasedRecord() {
        let (sut, userDefaults) = makeSUT()
        let productIdentifier = "an identifier"
        userDefaults.completeRetrieval(with: false, for: productIdentifier)
        
        let result = sut.hasPurchaseProduct(productIdentifier: productIdentifier)
        
        XCTAssertFalse(result)
    }
    
    func test_hasPurchaseProduct_deliversTrueForPurchasedRecord() {
        let (sut, userDefaults) = makeSUT()
        let productIdentifier = "an identifier"
        userDefaults.completeRetrieval(with: true, for: productIdentifier)
        
        let result = sut.hasPurchaseProduct(productIdentifier: productIdentifier)
        
        XCTAssertTrue(result)
    }
    
    func test_hasPurchaseProduct_hasNoSideEffectOnEmptyStore() {
        let (sut, userDefaults) = makeSUT()
        let productIdentifier = "an identifier"
        userDefaults.completeRetrieval(with: nil, for: productIdentifier)
        
        _ = sut.hasPurchaseProduct(productIdentifier: productIdentifier)
        
        XCTAssertEqual(userDefaults.receivedMessages, [.retrieveValue(forKey: productIdentifier)])
    }
    
    func test_hasPurchaseProduct_hasNoSideEffectOnInvalidPurchasedRecord() {
        let (sut, userDefaults) = makeSUT()
        let productIdentifier = "an identifier"
        userDefaults.completeRetrieval(with: false, for: productIdentifier)
        
        _ = sut.hasPurchaseProduct(productIdentifier: productIdentifier)
        
        XCTAssertEqual(userDefaults.receivedMessages, [.retrieveValue(forKey: productIdentifier)])
    }
    
    func test_hasPurchaseProduct_hasNoSideEffectOnPurchasedRecord() {
        let (sut, userDefaults) = makeSUT()
        let productIdentifier = "an identifier"
        userDefaults.completeRetrieval(with: true, for: productIdentifier)
        
        _ = sut.hasPurchaseProduct(productIdentifier: productIdentifier)
        
        XCTAssertEqual(userDefaults.receivedMessages, [.retrieveValue(forKey: productIdentifier)])
    }
    
    func test_insertPurchaseRecord_requestsUserDefaultsToSetPurchasedRecord() {
        let (sut, userDefaults) = makeSUT()
        let productIdentifier = "an identifier"
        
        sut.insertPurchaseRecord(productIdentifier: productIdentifier)
        
        XCTAssertEqual(userDefaults.receivedMessages, [.set(value: true, forKey: productIdentifier)])
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (UserDefaultsPurchaseRecordStore, UserDefaultsSpy) {
        let store = UserDefaultsSpy()
        let sut = UserDefaultsPurchaseRecordStore(userDefaults: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }

    final class UserDefaultsSpy: UserDefaults {
        private var values = [String: Bool]()
        
        enum Message: Equatable {
            case retrieveValue(forKey: String)
            case set(value: Bool, forKey: String)
        }
        
        private(set) var receivedMessages = [Message]()

        override func object(forKey defaultName: String) -> Any? {
            receivedMessages.append(.retrieveValue(forKey: defaultName))
            
            return values[defaultName]
        }
        
        override func set(_ value: Any?, forKey defaultName: String) {
            if let bool = value as? Bool {
                receivedMessages.append(.set(value: bool, forKey: defaultName))
            }
        }
        
        func completeRetrieval(with value: Bool?, for key: String) {
            values[key] = value
        }
    }
}
