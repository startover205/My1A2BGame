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
        canMakePayment: @escaping () -> Bool = SKPaymentQueue.canMakePayments
    ) -> IAPViewController {
        let iapController = UIStoryboard(name: "More", bundle: .init(for: IAPViewController.self)).instantiateViewController(withIdentifier: "IAPViewController") as! IAPViewController
        iapController.onRestoreCompletedTransactions = paymentQueue.restoreCompletedTransactions
        
        let presentationAdapter = ProductViewAdapter(iapViewController: iapController,
                                                     canMakePayment: canMakePayment,
                                                     paymentQueue: paymentQueue)
        
        let presenter = ProductPresenter(loader: MainQueueDispatchProductLoaderDecorator(decoratee: productLoader),
                                         loadingView: presentationAdapter,
                                         productView: presentationAdapter)
        
        iapController.onRefresh = presenter.retrieveAvailableProducts
        return iapController
    }
}

public final class MainQueueDispatchProductLoaderDecorator: IAPProductLoader {
    private static let key = DispatchSpecificKey<UInt8>()
    private static let value = UInt8.max
    private let decoratee: IAPProductLoader
    
    init(decoratee: IAPProductLoader) {
        self.decoratee = decoratee
        super.init(makeRequest: { _ in SKProductsRequest() }, getProductIDs: { [] })
        
        DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
    }
    
    private func isMainQueue() -> Bool {
        DispatchQueue.getSpecific(key: Self.key) == Self.value
    }
    
    public override func load(completion: @escaping ([SKProduct]) -> Void) {
        decoratee.load { [weak self] result in
            guard let self = self else { return }
            
            if self.isMainQueue() {
                completion(result)
            } else {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}

final class ProductViewAdapter {
    private weak var iapViewController: IAPViewController?
    private let canMakePayment: () -> Bool
    private let paymentQueue: SKPaymentQueue
    
    init(iapViewController: IAPViewController, canMakePayment: @escaping () -> Bool, paymentQueue: SKPaymentQueue) {
        self.iapViewController = iapViewController
        self.canMakePayment = canMakePayment
        self.paymentQueue = paymentQueue
    }
}


extension ProductViewAdapter: ProductLoadingView {
    func display(_ viewModel: ProductLoadingViewModel) {
        if viewModel.isLoading {
            iapViewController?.tableView.tableHeaderView = nil
            iapViewController?.refreshControl?.beginRefreshing()
        } else {
            iapViewController?.refreshControl?.endRefreshing()
        }
    }
}

extension ProductViewAdapter: ProductView {
    func display(_ viewModel: ProductListViewModel) {
        if viewModel.products.isEmpty {
            iapViewController?.tableView.tableHeaderView = makeNoProductLabel()
        }
        
        iapViewController?.tableModel = viewModel.products.map { product in
            IAPCellController(product: ProductViewModel(name: product.localizedTitle, price: product.localPrice)) { [weak self] in
                guard let self = self else { return }
                
                if self.canMakePayment() {
                    let payment = SKPayment(product: product)
                    self.paymentQueue.add(payment)
                } else {
                    let alert = UIAlertController(title: ProductPresenter.noPaymentMessage, message: ProductPresenter.noPaymentDetailedMessage, preferredStyle: .alert)
                    
                    let ok = UIAlertAction(title: ProductPresenter.noPaymentMessageDismissAction, style: .default)
                    
                    alert.addAction(ok)
                    
                    self.iapViewController?.showDetailViewController(alert, sender: self)
                }
            }
        }
    }
    
    private func makeNoProductLabel() -> UILabel {
        let label = UILabel()
        label.text = ProductPresenter.noProductMessage
        label.textColor = .white
        label.backgroundColor = .lightGray
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }
}

