//
//  IAPUIComposer.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/11/11.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit
import StoreKit

protocol ProductLoadingView {
    func display(_ viewModel: ProductLoadingViewModel)
}

struct ProductLoadingViewModel {
    let isLoading: Bool
}

protocol ProductView {
    func display(_ viewModel: ProductViewModel)
}

struct ProductViewModel {
    let products: [SKProduct]
}

public final class ProductPresenter {
    private let loader: IAPProductLoader
    private let loadingView: ProductLoadingView
    private let productView: ProductView
    
    init(loader: IAPProductLoader, loadingView: ProductLoadingView, productView: ProductView) {
        self.loader = loader
        self.loadingView = loadingView
        self.productView = productView
    }
    
    func retrieveAvailableProducts() {
        loadingView.display(ProductLoadingViewModel(isLoading: true))
        
        loader.load { [weak self] products in
            guard let self = self else { return }
            
            self.loadingView.display(ProductLoadingViewModel(isLoading: false))
            
            self.productView.display(ProductViewModel(products: products))
        }
    }
}

extension ProductPresenter {
    public static var noPaymentMessage: String {
        NSLocalizedString("NO_PAYMENT_MESSAGE",
                          tableName: nil,
                          bundle: Bundle(for: ProductPresenter.self),
                          comment: "The message for user payment not available")
    }
    
    public static var noPaymentDetailedMessage: String {
        NSLocalizedString("NO_PAYMENT_MESSAGE_DETAILED",
                          tableName: nil,
                          bundle: Bundle(for: ProductPresenter.self),
                          comment: "The detailed message for user payment not available")
    }
    
    public static var noPaymentMessageDismissAction: String {
        NSLocalizedString("NO_PAYMENT_CONFIRM_ACTION",
                          tableName: nil,
                          bundle: Bundle(for: ProductPresenter.self),
                          comment: "The button for dismissing the no payment message")
    }
    
    public static var noProductMessage: String {
        NSLocalizedString("NO_PRODUCT_MESSAGE",
                          tableName: nil,
                          bundle: Bundle(for: ProductPresenter.self),
                          comment: "The message when there are no products to buy")
    }
}


public final class IAPUIComposer {
    private init() {}
    
    public static func iapComposedWith(productLoader: IAPProductLoader,
                                       paymentQueue: SKPaymentQueue,
                                       canMakePayment: @escaping () -> Bool = SKPaymentQueue.canMakePayments) -> IAPViewController {
        let iapController = UIStoryboard(name: "More", bundle: .init(for: IAPViewController.self)).instantiateViewController(withIdentifier: "IAPViewController") as! IAPViewController
        iapController.onRestoreCompletedTransactions = paymentQueue.restoreCompletedTransactions
        
        let presentationAdapter = ProductViewAdapter(iapViewController: iapController,
                                                             canMakePayment: canMakePayment,
                                                             paymentQueue: paymentQueue)
        
        let presenter = ProductPresenter(loader: productLoader,
                                         loadingView: presentationAdapter,
                                         productView: presentationAdapter)
        
        iapController.onRefresh = presenter.retrieveAvailableProducts
        return iapController
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
    func display(_ viewModel: ProductViewModel) {
        if viewModel.products.isEmpty {
            iapViewController?.tableView.tableHeaderView = makeNoProductLabel()
        }
        
        iapViewController?.tableModel = viewModel.products.map { product in
            IAPCellController(product: Product(name: product.localizedTitle, price: product.localPrice)) { [weak self] in
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

