//
//  IAPTransactionObserver.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/4/12.
//  Copyright © 2019 Ming-Ta Yang. All rights reserved.
//

import Foundation
import StoreKit

class IAPTransactionObserver: NSObject, SKPaymentTransactionObserver {
    
    static let shared = IAPTransactionObserver()
    weak var delegate: IAPTransactionObserverDelegate?
    private var finishedTransactionIDs = [String]()
    var hasRestorableContent = false
    var restorationDelegate: IAPRestorationDelegate?
    var onTransactionError: ((Error?) -> Void)?
    var onPurchaseProduct: ((String) -> Void)?
    
    private override init() {
        super.init()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            
            switch transaction.transactionState {
            case .purchased :
                if let id = transaction.transactionIdentifier, finishedTransactionIDs.contains(id) {
                    SKPaymentQueue.default().finishTransaction(transaction)
                    continue
                }
                
                guard let handler = onPurchaseProduct else { continue }
                
                let productIdentifier = transaction.payment.productIdentifier
                
                handler(productIdentifier)
                
                SKPaymentQueue.default().finishTransaction(transaction)
                
                transaction.transactionIdentifier.map { finishedTransactionIDs.append($0) }
                
                delegate?.didPuarchaseIAP(productIdenifer: productIdentifier)
                
            case .failed :
                guard (transaction.error as? SKError)?.code != .paymentCancelled else {
                    SKPaymentQueue.default().finishTransaction(transaction)
                    continue
                }
                
                guard let handler = onTransactionError else { continue }
                
                handler(transaction.error)
                
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .restored:
                guard let handler = onPurchaseProduct else { continue }
                
                hasRestorableContent = true
                
                let productIdentifier = transaction.payment.productIdentifier
                handler(productIdentifier)
                SKPaymentQueue.default().finishTransaction(transaction)
                
            default:
                break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        restorationDelegate?.restorationFinished(hasRestorableContent: hasRestorableContent)
        
        delegate?.didRestoreIAP()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        guard (error as? SKError)?.code != .paymentCancelled else { return }

        restorationDelegate?.restorationFinished(with: error)
    }
}

// MARK: - Private
private extension IAPTransactionObserver {
    func presentAlertOnRootController(alertController: UIAlertController, animated: Bool, completion: (()->())? = nil){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController?.present(alertController, animated: animated, completion: completion)
    }
}

protocol IAPTransactionObserverDelegate: AnyObject {
    func didPuarchaseIAP(productIdenifer: String)
    func didRestoreIAP()
}

protocol IAPRestorationDelegate {
    func restorationFinished(with error: Error)
    func restorationFinished(hasRestorableContent: Bool)
}
