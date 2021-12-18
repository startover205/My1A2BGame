//
//  IAPUIComposer.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/11/11.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit
import StoreKit

public final class IAPUIComposer {
    private init() {}
    
    public static func iapComposedWith(
        productLoader: IAPProductLoader,
        paymentQueue: SKPaymentQueue,
        canMakePayment: @escaping () -> Bool = SKPaymentQueue.canMakePayments) -> IAPViewController {
        let iapController = UIStoryboard(name: "More", bundle: .init(for: IAPViewController.self)).instantiateViewController(withIdentifier: "IAPViewController") as! IAPViewController
        iapController.onRestoreCompletedTransactions = paymentQueue.restoreCompletedTransactions
        
        iapController.onRefresh = { [weak iapController] in
            guard let iapController = iapController else { return }
            
            iapController.tableView.tableHeaderView = nil
            
            iapController.refreshControl?.beginRefreshing()
            
            productLoader.load(completion: { [weak iapController] products in
                guard let iapController = iapController else { return }
                
                iapController.tableModel = self.adaptProductsToCellControllers(products, selection: { [weak iapController] in
                    if canMakePayment() {
                        let payment = SKPayment(product: $0)
                        paymentQueue.add(payment)
                    } else {
                        let alert = UIAlertController(title: NSLocalizedString("NO_PAYMENT_MESSAGE", comment: ""), message: NSLocalizedString("NO_PAYMENT_MESSAGE_DETAILED", comment: ""), preferredStyle: .alert)
                        
                        let ok = UIAlertAction(title: NSLocalizedString("NO_PAYMENT_CONFIRM_ACTION", comment: ""), style: .default)
                        
                        alert.addAction(ok)
                        
                        iapController?.showDetailViewController(alert, sender: self)
                    }
                })
                
                iapController.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .left)
                iapController.refreshControl?.endRefreshing()
                
                if iapController.tableModel.isEmpty {
                    iapController.tableView.tableHeaderView = makeNoProductLabel()
                }
            })
        }
        
        return iapController
    }
    
    private static func makeNoProductLabel() -> UILabel {
        let label = UILabel()
        label.text = NSLocalizedString("NO_PRODUCT_MESSAGE", comment: "3nd")
        label.textColor = .white
        label.backgroundColor = .lightGray
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }
}


extension IAPUIComposer {
    private static func adaptProductsToCellControllers(_ products: [SKProduct], selection: @escaping (SKProduct) -> Void) -> [IAPCellController] {
        products.map { product in
            IAPCellController(product: Product(name: product.localizedTitle, price: product.localPrice)) {
               selection(product)
            }
        }
    }
}

