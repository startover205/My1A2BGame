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

func oneValidProduct() -> SKProduct {
    let product = SKProduct()
    product.setValue("a product name", forKey: "localizedTitle")
    product.setValue("remove_bottom_ad", forKey: "productIdentifier")
    product.setValue(0.99, forKey: "price")
    product.setValue(Locale(identifier: "en_US_POSIX"), forKey: "priceLocale")

    return product
}

func makeProduct(identifier: String = "product identifier", name: String = "product name", locale: Locale = Locale(identifier: "en_US_POSIX"), price: NSDecimalNumber = 0.99) -> SKProduct {
    let product = SKProduct()
    product.setValue(name, forKey: "localizedTitle")
    product.setValue(identifier, forKey: "productIdentifier")
    product.setValue(price, forKey: "price")
    product.setValue(locale, forKey: "priceLocale")
    
    return product
}

func makePurchasedTransaction(with product: SKProduct, transactionIdentifier: String? = nil) -> SKPaymentTransaction {
    TransactionStub(product: product, transactionState: .purchased, transactionidentifier: transactionIdentifier)
}

func makeRestoredTransaction(with product: SKProduct = oneValidProduct()) -> SKPaymentTransaction {
    TransactionStub(product: product, transactionState: .restored, transactionidentifier: nil)
}

private final class TransactionStub: SKPaymentTransaction {
    private let _transactionState: SKPaymentTransactionState
    private let _payment: SKPayment
    private let _transactionIdentifier: String?
    
    init(product: SKProduct, transactionState: SKPaymentTransactionState, transactionidentifier: String?) {
        self._payment = SKPayment(product: product)
        self._transactionState = transactionState
        self._transactionIdentifier = transactionidentifier
    }
    
    override var transactionState: SKPaymentTransactionState { _transactionState }
    override var transactionIdentifier: String? { _transactionIdentifier }
    override var payment: SKPayment { _payment }
}
