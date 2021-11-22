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
                
                let productIdentifier = transaction.payment.productIdentifier
                
                handlePurchase(productIdentifier: productIdentifier)
                
                SKPaymentQueue.default().finishTransaction(transaction)
                
                transaction.transactionIdentifier.map { finishedTransactionIDs.append($0) }
                
                delegate?.didPuarchaseIAP(productIdenifer: productIdentifier)
                
            case .failed :
                
                SKPaymentQueue.default().finishTransaction(transaction)
                
                guard let skError = transaction.error as? SKError, skError.code != .paymentCancelled else { return }
                
                let message = skError.localizedDescription
                
                ErrorManager.saveError(description: message)
                
                let alert = UIAlertController(title: NSLocalizedString("Failed to Purchase", comment: "5th"), message: message, preferredStyle: .alert)
                
                let ok = UIAlertAction(title: NSLocalizedString("Confirm", comment: "3nd"), style: .default)
                
                alert.addAction(ok)
                
                presentAlertOnRootController(alertController: alert, animated: true)
            case .restored:
                hasRestorableContent = true
                 let productIdentifier = transaction.payment.productIdentifier
                
                 handlePurchase(productIdentifier: productIdentifier)
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
    func handlePurchase(productIdentifier: String){
        
        guard let product = IAP(rawValue: productIdentifier) else {
            
            ErrorManager.saveError(description: "\(#function)-invalid productionIdentifier")
            
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "3nd"), message: NSLocalizedString("Unknown product identifier, please contact Apple for refund if payment is complete or send a bug report.", comment: "3nd"), preferredStyle: .alert)
            
            let ok = UIAlertAction(title: NSLocalizedString("Confirm", comment: "3nd"), style: .default)
            
            alert.addAction(ok)
            
            presentAlertOnRootController(alertController: alert, animated: true)
            
            return
        }
        
        IAP.didPurchase(product: product, userDefaults: .standard)
    }
    
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

extension SKProduct {
    var localPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
