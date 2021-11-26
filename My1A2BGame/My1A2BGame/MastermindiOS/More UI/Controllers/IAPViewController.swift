//
//  IAPViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/4/11.
//  Copyright © 2019 Ming-Ta Yang. All rights reserved.
//

import UIKit
import StoreKit

public class IAPViewController: UITableViewController {
    
    @IBOutlet private(set) public weak var restorePurchaseButton: UIBarButtonItem!
    
    var tableModel = [IAPCellController]()
    var productLoader: IAPProductLoader?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        restorePurchaseButton.isEnabled = SKPaymentQueue.canMakePayments()
        
        refresh()
    }
    
    @IBAction func reloadProducts(_ sender: Any) {
        refresh()
    }
    
    @IBAction func restoreBtnPressed(_ sender: Any) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func refresh(){
        if !tableModel.isEmpty{
            tableModel.removeAll()
            tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .left)
        }
        
        let productIDs = IAP.getAvailableProductsId(userDefaults: .standard)
        
        refreshControl?.beginRefreshing()
        
        if SKPaymentQueue.canMakePayments() {
            productLoader?.load(productIDs: productIDs, completion: { [weak self] products in
                guard let self = self else { return }
                
                self.tableModel = self.adaptProductsToCellControllers(products)
                
                self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .left)
                self.refreshControl?.endRefreshing()
                
                if self.tableModel.isEmpty {
                    let alert = UIAlertController(title: NSLocalizedString("NO_PRODUCT_MESSAGE", comment: "3nd"), message: nil, preferredStyle: .alert)
                    
                    let ok = UIAlertAction(title: NSLocalizedString("Confirm", comment: "3nd"), style: .default)
                    
                    alert.addAction(ok)
                    
                    self.showDetailViewController(alert, sender: self)
                }
            })
            
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Purchase not available", comment: "4th"), message: NSLocalizedString("Sorry, it seems purchase is not available on this device or within this app.", comment: "4th"), preferredStyle: .alert)
            
            let ok = UIAlertAction(title: NSLocalizedString("Confirm", comment: "3nd"), style: .default)
            
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    // MARK: - Table view delegate
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(at: indexPath).tableView(tableView, cellForRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellController(at: indexPath).tableView(tableView, didSelectRowAt: indexPath)
    }
    
    private func cellController(at indexPath: IndexPath) -> IAPCellController {
       tableModel[indexPath.row]
    }
}

extension IAPViewController: IAPTransactionObserverDelegate {
    func didPuarchaseIAP(productIdenifer: String) {
        refresh()
    }
    func didRestoreIAP() {
        refresh()
    }
}

extension IAPViewController {
    private func adaptProductsToCellControllers(_ products: [SKProduct]) -> [IAPCellController] {
        products.map { product in
            IAPCellController(product: Product(name: product.localizedTitle, price: product.localPrice)) {
                 let payment = SKPayment(product: product)
                 SKPaymentQueue.default().add(payment)
            }
        }
    }
}

