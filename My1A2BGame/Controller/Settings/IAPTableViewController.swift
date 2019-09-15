//
//  IAPTableViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/4/11.
//  Copyright © 2019 Ming-Ta Yang. All rights reserved.
//

import UIKit
import StoreKit

class IAPTableViewController: UITableViewController {
    
    @IBOutlet weak var restorePurchaeBtn: UIBarButtonItem!
    
    var objects = [SKProduct]()
    var productIdList = [String]()
    var productRequest: SKProductsRequest?
    weak var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StoreObserver.shared.delegate = self
        
         restorePurchaeBtn.isEnabled = SKPaymentQueue.canMakePayments()
        
        refresh()
    }
    @IBAction func restoreBtnPressed(_ sender: Any) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IAPProductCell", for: indexPath) as! IAPTableViewCell
        
        let object = objects[indexPath.row]
        cell.productNameLabel.text = object.localizedTitle
        cell.productPriceLabel.text = object.localPrice
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = objects[indexPath.row]
        let payment = SKPayment(product: object)
        SKPaymentQueue.default().add(payment)
    }
}

extension IAPTableViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        objects = response.products
        tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .left)

        activityIndicator?.removeFromSuperview()
        
        if objects.isEmpty {
            let alert = UIAlertController(title: NSLocalizedString("Currently No Product Available", comment: "3nd"), message: nil, preferredStyle: .alert)
            
            let ok = UIAlertAction(title: NSLocalizedString("Confirm", comment: "3nd"), style: .default)
            
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        #if DEBUG
        print("invalidProductIdentifiers: \(response.invalidProductIdentifiers.description)")
        #endif
    }
}

extension IAPTableViewController: StoreObserverDelegate {
    func didPuarchaseIAP(productIdenifer: String) {
        refresh()
    }
    func didRestoreIAP() {
        refresh()
    }
}

// MARK: - Private
private extension IAPTableViewController {
    func refresh(){
        if !objects.isEmpty{
            objects.removeAll()
            tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .left)
        }
        
        productIdList = IAP.getAvailableProductsId()
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        self.activityIndicator = activityIndicator
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        requestProductInfo()
    }
    
    func requestProductInfo(){
        if SKPaymentQueue.canMakePayments() {
            let productRequest = SKProductsRequest(productIdentifiers: Set(productIdList))
            self.productRequest = productRequest
            productRequest.delegate = self
            productRequest.start()
            
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Purchase not available", comment: "4th"), message: NSLocalizedString("Sorry, it seems purchase is not available on this device or within this app", comment: "4th"), preferredStyle: .alert)
            
            let ok = UIAlertAction(title: NSLocalizedString("Confirm", comment: "3nd"), style: .default)
            
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

