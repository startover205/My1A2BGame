//
//  IAPTransactionObserver.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/4/12.
//  Copyright © 2019 Ming-Ta Yang. All rights reserved.
//

import Foundation
import StoreKit

public class IAPTransactionObserver: NSObject, SKPaymentTransactionObserver {
    
    static let shared = IAPTransactionObserver()
    private var finishedTransactionIDs = [String]()
    private var hasRestorableContent = false
    public var onTransactionError: ((Error?) -> Void)?
    public var onPurchaseProduct: ((String) -> Void)?
    public var onRestoreProduct: ((String) -> Void)?
    public var onRestorationFinishedWithError: ((Error) -> Void)?
    public var onRestorationFinished: ((_ hasRestorableContent: Bool) -> Void)?
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            
            switch transaction.transactionState {
            case .purchased :
                if let id = transaction.transactionIdentifier, finishedTransactionIDs.contains(id) {
                    queue.finishTransaction(transaction)
                    continue
                }
                
                guard let handler = onPurchaseProduct else { continue }
                
                let productIdentifier = transaction.payment.productIdentifier
                handler(productIdentifier)
                queue.finishTransaction(transaction)
                
                transaction.transactionIdentifier.map { finishedTransactionIDs.append($0) }
                
            case .failed :
                guard (transaction.error as? SKError)?.code != .paymentCancelled else {
                    queue.finishTransaction(transaction)
                    continue
                }
                
                guard let handler = onTransactionError else { continue }
                
                handler(transaction.error)
                
                queue.finishTransaction(transaction)
                
            case .restored:
                hasRestorableContent = true

                guard let handler = onRestoreProduct else { continue }
                
                let productIdentifier = transaction.payment.productIdentifier
                handler(productIdentifier)
                queue.finishTransaction(transaction)
                
            default:
                break
            }
        }
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        onRestorationFinished?(hasRestorableContent)
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        onRestorationFinishedWithError?(error)
    }
}
