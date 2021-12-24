//
//  ProductPresenter.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/12/21.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

final class ProductPresenter {
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
            
            self.productView.display(ProductListViewModel(products: products))
        }
    }
}

extension ProductPresenter {
    public static var noPaymentMessage: String {
        NSLocalizedString("NO_PAYMENT_MESSAGE",
                          tableName: "InAppPurchase",
                          bundle: Bundle(for: ProductPresenter.self),
                          comment: "The message for user payment not available")
    }
    
    public static var noPaymentDetailedMessage: String {
        NSLocalizedString("NO_PAYMENT_MESSAGE_DETAILED",
                          tableName: "InAppPurchase",
                          bundle: Bundle(for: ProductPresenter.self),
                          comment: "The detailed message for user payment not available")
    }
    
    public static var noPaymentMessageDismissAction: String {
        NSLocalizedString("NO_PAYMENT_CONFIRM_ACTION",
                          tableName: "InAppPurchase",
                          bundle: Bundle(for: ProductPresenter.self),
                          comment: "The button for dismissing the no payment message")
    }
    
    public static var noProductMessage: String {
        NSLocalizedString("NO_PRODUCT_MESSAGE",
                          tableName: "InAppPurchase",
                          bundle: Bundle(for: ProductPresenter.self),
                          comment: "The message when there are no products to buy")
    }
}
