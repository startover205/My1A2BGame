//
//  IAPAcceptanceTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/11/25.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import StoreKitTest
@testable import My1A2BGame

@available(iOS 14.0, *)
class IAPAcceptanceTests: XCTestCase {

    func test_iap_handleTransactions_doesNotShowMessageOnPurchaseFailedWithCancellation() throws {
        let rootVC = try XCTUnwrap((UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController)
        
        simulateFailedTransactionWithCancellation()
        
        XCTAssertNil(rootVC.presentedViewController)
    }
    
    func test_iap_handleTransactions_showsMessageOnPurchaseFailed() throws {
        let rootVC = try XCTUnwrap((UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController)
        
        try simulateFailedTransaction()
        
        let alert = try XCTUnwrap(rootVC.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.title, "Failed to Purchase", "alert title")
        XCTAssertEqual(alert.message, "UNKNOWN_ERROR", "alert message")
        XCTAssertEqual(alert.actions.first?.title, "Confirm", "confirm title")
        
        clearModalPresentationReference(rootVC)
    }
    
    func test_iap_handlePurchase_showsMessageOnPurchasingUnknownProduct() throws {
        let rootVC = try XCTUnwrap((UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController)
        let unknownProduct = unknownProdcut()
        try createLocalTestSession("Unknown")
        
        SKPaymentQueue.default().add(SKPayment(product: unknownProduct))
        
        let exp = expectation(description: "wait for request")
        exp.isInverted = true
        wait(for: [exp], timeout: 0.5)
        
        let alert = try XCTUnwrap(rootVC.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.title, "Error", "alert title")
        XCTAssertEqual(alert.message, "Unknown product identifier, please contact Apple for refund if payment is complete or send a bug report.", "alert message")
        XCTAssertEqual(alert.actions.first?.title, "Confirm", "confirm title")
        
        clearModalPresentationReference(rootVC)
    }
    
    func test_iap_handlePurchase_removesBottomADOnSuccessfulPurchaseOrRestoration() throws {
        cleanPurchaseRecordInApp()
        let tabController = try XCTUnwrap(launch() as? BannerAdTabBarViewController)
        let removeBottomADProduct = removeBottomADProduct()
        tabController.triggerLifecycleForcefully()
        
        let initialInset = tabController.children.first?.additionalSafeAreaInsets
        XCTAssertNotEqual(initialInset, .zero, "Expect addtional insets not zero due to spacing for AD")
        
        try simulateSuccessfullyPurchasedTransaction(product: removeBottomADProduct)
        
        let anotherTabController = try XCTUnwrap(launch() as? BannerAdTabBarViewController)
        anotherTabController.triggerLifecycleForcefully()
        let finalInset = anotherTabController.children.first?.additionalSafeAreaInsets
        XCTAssertEqual(finalInset, .zero, "Expect addtional insets zero now the AD is removed")
        
        cleanPurchaseRecordInApp()
        simulateSuccessfulRestoration()
        
        let andAnotherTabController = try XCTUnwrap(launch() as? BannerAdTabBarViewController)
        andAnotherTabController.triggerLifecycleForcefully()
        let insetAfterRestoration = andAnotherTabController.children.first?.additionalSafeAreaInsets
        XCTAssertEqual(insetAfterRestoration, .zero, "Expect addtional insets zero because the AD is removed again")
    }
    
    func test_iap_restoreCompletedTransactions_doesNotShowsMessageOnPaymenCancelledError() throws {
        let rootVC = try XCTUnwrap((UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController)
        let restorationError = SKError(.paymentCancelled)
        
        simulateRestoreCompletedTransactionFailed(with: restorationError)
        
        XCTAssertNil(rootVC.presentedViewController)
    }
    
    func test_iap_restoreCompletedTransactions_showsMessageOnRestorationError() throws {
        let rootVC = try XCTUnwrap((UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController)
        let restorationError = anyNSError()
        
        simulateRestoreCompletedTransactionFailed(with: restorationError)
        
        let alert = try XCTUnwrap(rootVC.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.title, "Failed to Restore Purchase", "alert title")
        XCTAssertEqual(alert.message, restorationError.localizedDescription, "alert message")
        XCTAssertEqual(alert.actions.first?.title, "Confirm", "confirm title")
        
        clearModalPresentationReference(rootVC)
    }
    
    func test_iap_restoreCompletedTransactions_showsMessageOnSuccessfulEmptyRestoration() throws {
        let rootVC = try XCTUnwrap((UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController)
        
        try createLocalTestSession()
        simulateSuccessfulRestoration()
        
        let alert = try XCTUnwrap(rootVC.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.title, "No Restorable Products", "alert title")
        XCTAssertEqual(alert.actions.first?.title, "Confirm", "confirm title")
        
        clearModalPresentationReference(rootVC)
    }
    
    func test_iap_restoreCompletedTransactions_showsMessageOnSuccessfulNonEmptyRestoration() throws {
        let rootVC = try XCTUnwrap((UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController)
        
        try simulateSuccessfullyPurchasedTransaction(product: aProduct())
        simulateSuccessfulRestoration()
        
        let alert = try XCTUnwrap(rootVC.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.title, "Successfully Restored Purchase", "alert title")
        XCTAssertEqual(alert.message, "Certain content will only be available after restarting the app.", "alert message")
        XCTAssertEqual(alert.actions.first?.title, "Confirm", "confirm title")
        
        clearModalPresentationReference(rootVC)
    }
    
    // MARK: - Helpers
    
    private func launch(transactionObserver: IAPTransactionObserver = IAPTransactionObserver(), paymentQueue: SKPaymentQueue = .init()) -> UITabBarController {
        let sut = AppDelegate(transactionObserver: transactionObserver, paymentQueue: paymentQueue)
        sut.window = UIWindow()
        sut.configureWindow()
        
        return sut.window?.rootViewController as! UITabBarController
    }

    private func cleanPurchaseRecordInApp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    func simulateRestoreCompletedTransactionFailed(with error: Error) {
        IAPTransactionObserver.shared.paymentQueue(SKPaymentQueue(), restoreCompletedTransactionsFailedWithError: error)
    }
}

extension UIViewController {
    func triggerLifecycleIfNeeded() {
        guard !isViewLoaded else { return }
        
        loadViewIfNeeded()
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func triggerLifecycleForcefully() {
        loadViewIfNeeded()
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
}

private func unknownProdcut() -> SKProduct {
    let product = SKProduct()
    product.setValue("com.temporary.id", forKey: "productIdentifier")
    return product
}

private func removeBottomADProduct() -> SKProduct {
    let product = SKProduct()
    product.setValue("remove_bottom_ad", forKey: "productIdentifier")
    return product
}

private func simulateFailedTransactionWithCancellation() {
    IAPTransactionObserver.shared.paymentQueue(SKPaymentQueue(), updatedTransactions: [makeFailedTransaction(with: .paymentCancelled)])
}

