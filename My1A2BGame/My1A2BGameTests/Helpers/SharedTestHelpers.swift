//
//  SharedTestHelpers.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/8/24.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import Foundation
import Mastermind
import StoreKit

func anyNSError() -> NSError { NSError(domain: "any error", code: 0) }

func anyPlayerRecord() -> PlayerRecord {
    PlayerRecord(playerName: "a name", guessCount: 10, guessTime: 10, timestamp: Date())
}

func makeFailedTransaction(with error: SKError.Code) -> SKPaymentTransaction {
    let transaction = SKPaymentTransaction()
    transaction.setValue(SKPaymentTransactionState.failed.rawValue, forKey: "transactionState")
    transaction.setValue(SKError(error), forKey: "error")
    return transaction
}

func makePurchasedTransaction(with product: SKProduct) -> SKPaymentTransaction {
    PurchasedTransaction(product: product)
}

private final class PurchasedTransaction: SKPaymentTransaction {
    private let _transactionState: SKPaymentTransactionState = .purchased
    private let _payment: SKPayment
    
    init(product: SKProduct) {
        self._payment = SKPayment(product: product)
    }
    
    override var transactionState: SKPaymentTransactionState { _transactionState }
    
    override var payment: SKPayment { _payment }
}
