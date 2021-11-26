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
    
    public static func iapComposedWith(productLoader: IAPProductLoader) -> IAPViewController {
        let iapController = UIStoryboard(name: "More", bundle: .init(for: IAPViewController.self)).instantiateViewController(withIdentifier: "IAPViewController") as! IAPViewController
        iapController.productLoader = productLoader
        iapController.onRestoreCompletedTransactions = {
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
        
        iapController.onRefresh = { [weak iapController] in
            guard let iapController = iapController else { return }
            
            let productIDs = IAP.getAvailableProductsId(userDefaults: .standard)
            
            iapController.refreshControl?.beginRefreshing()
            
            if SKPaymentQueue.canMakePayments() {
                productLoader.load(productIDs: productIDs, completion: { [weak iapController] products in
                    guard let iapController = iapController else { return }
                    
                    iapController.tableModel = self.adaptProductsToCellControllers(products)
                    
                    iapController.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .left)
                    iapController.refreshControl?.endRefreshing()
                    
                    if iapController.tableModel.isEmpty {
                        let alert = UIAlertController(title: NSLocalizedString("NO_PRODUCT_MESSAGE", comment: "3nd"), message: nil, preferredStyle: .alert)
                        
                        let ok = UIAlertAction(title: NSLocalizedString("Confirm", comment: "3nd"), style: .default)
                        
                        alert.addAction(ok)
                        
                        iapController.showDetailViewController(alert, sender: self)
                    }
                })
                
            } else {
                let alert = UIAlertController(title: NSLocalizedString("Purchase not available", comment: "4th"), message: NSLocalizedString("Sorry, it seems purchase is not available on this device or within this app.", comment: "4th"), preferredStyle: .alert)
                
                let ok = UIAlertAction(title: NSLocalizedString("Confirm", comment: "3nd"), style: .default)
                
                alert.addAction(ok)
                
                iapController.present(alert, animated: true)
            }
        }
        
        return iapController
    }
}


extension IAPUIComposer {
    private static func adaptProductsToCellControllers(_ products: [SKProduct]) -> [IAPCellController] {
        products.map { product in
            IAPCellController(product: Product(name: product.localizedTitle, price: product.localPrice)) {
                 let payment = SKPayment(product: product)
                 SKPaymentQueue.default().add(payment)
            }
        }
    }
}

