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

    func test_iap_handleTransactions_doesNotShowMessageOnPurchaseFailedWithCancellation() {
        let (tabController, transactionObserver, paymentQueue) = launch()
        
        transactionObserver.simulateFailedTransactionWithCancellation(from: paymentQueue)
        
        XCTAssertNil(tabController.presentedViewController)
    }
    
    func test_iap_handleTransactions_showsMessageOnPurchaseFailed() throws {
        let (tabController, transactionObserver, paymentQueue) = launch()
        
        transactionObserver.simulateFailedTransaction(with: .unknown, from: paymentQueue)
        
        let alert = try XCTUnwrap(tabController.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.title, "Failed to Purchase", "alert title")
        XCTAssertEqual(alert.message, "The operation couldn’t be completed. (SKErrorDomain error 0.)", "alert message")
        XCTAssertEqual(alert.actions.first?.title, "Confirm", "confirm title")
    }
    
    func test_iap_handlePurchase_showsMessageOnPurchasingUnknownProduct() throws {
        let (tabController, transactionObserver, paymentQueue) = launch()
        let unknownProduct = unknownProdcut()
        
        try createLocalTestSession("Unknown")
        simulateBuying(unknownProduct, observer: transactionObserver, paymentQueue: paymentQueue)
        
        let alert = try XCTUnwrap(tabController.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.title, "Error", "alert title")
        XCTAssertEqual(alert.message, "Unknown product identifier, please contact Apple for refund if payment is complete or send a bug report.", "alert message")
        XCTAssertEqual(alert.actions.first?.title, "Confirm", "confirm title")
    }

    func test_iap_restoreCompletedTransactions_doesNotShowsMessageOnPaymenCancelledError() {
        let (tabController, transactionObserver, paymentQueue) = launch()
        let restorationError = SKError(.paymentCancelled)

        transactionObserver.simulateRestoreCompletedTransactionFailed(with: restorationError, from: paymentQueue)

        XCTAssertNil(tabController.presentedViewController)
    }

    func test_iap_restoreCompletedTransactions_showsMessageOnRestorationError() throws {
        let (tabController, transactionObserver, paymentQueue) = launch()
        let restorationError = anyNSError()

        transactionObserver.simulateRestoreCompletedTransactionFailed(with: restorationError, from: paymentQueue)

        let alert = try XCTUnwrap(tabController.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.title, "Failed to Restore Purchase", "alert title")
        XCTAssertEqual(alert.message, restorationError.localizedDescription, "alert message")
        XCTAssertEqual(alert.actions.first?.title, "Confirm", "confirm title")
    }

    func test_iap_restoreCompletedTransactions_showsMessageOnSuccessfulEmptyRestoration() throws {
        let (tabController, transactionObserver, paymentQueue) = launch()

        try createLocalTestSession()
        simulateRestoringCompletedTransactions(observer: transactionObserver, paymentQueue: paymentQueue)

        let alert = try XCTUnwrap(tabController.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.title, "No Restorable Products", "alert title")
        XCTAssertEqual(alert.actions.first?.title, "Confirm", "confirm title")
    }
    
    func test_iap_restoreCompletedTransactions_showsMessageOnSuccessfulNonEmptyRestoration() throws {
        let (tabController, transactionObserver, paymentQueue) = launch()
        
        try createLocalTestSession()
        simulateBuying(aProduct(), observer: transactionObserver, paymentQueue: paymentQueue)
        simulateRestoringCompletedTransactions(observer: transactionObserver, paymentQueue: paymentQueue)
        
        let alert = try XCTUnwrap(tabController.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.title, "Successfully Restored Purchase", "alert title")
        XCTAssertEqual(alert.message, "Certain content will only be available after restarting the app.", "alert message")
        XCTAssertEqual(alert.actions.first?.title, "Confirm", "confirm title")
    }
    
    // MARK: - Product

    func test_iap_handlePurchase_removesBottomADOnSuccessfulPurchaseOrRestoration() throws {
        cleanPurchaseRecordInApp()
        var (adController, transactionObserver, paymentQueue) = try launchWithAdControl()
        let removeBottomADProduct = removeBottomADProduct()
        adController.triggerLifecycleForcefully()

        let initialInset = adController.children.first?.additionalSafeAreaInsets
        XCTAssertNotEqual(initialInset, .zero, "Expect addtional insets not zero due to spacing for AD")
        
        try createLocalTestSession()
        simulateBuying(removeBottomADProduct, observer: transactionObserver, paymentQueue: paymentQueue)

        (adController, transactionObserver, paymentQueue) = try launchWithAdControl()
        adController.triggerLifecycleForcefully()
        let finalInset = adController.children.first?.additionalSafeAreaInsets
        XCTAssertEqual(finalInset, .zero, "Expect addtional insets zero now the AD is removed")

        cleanPurchaseRecordInApp()
        simulateRestoringCompletedTransactions(observer: transactionObserver, paymentQueue: paymentQueue)

        (adController, transactionObserver, paymentQueue) = try launchWithAdControl()
        adController.triggerLifecycleForcefully()
        let insetAfterRestoration = adController.children.first?.additionalSafeAreaInsets
        XCTAssertEqual(insetAfterRestoration, .zero, "Expect addtional insets zero because the AD is removed again")
    }
    
    // MARK: - Helpers
    
    private func launch() -> (UITabBarController, IAPTransactionObserver, SKPaymentQueue) {
        let transactionObserver = IAPTransactionObserver()
        let paymentQueue = SKPaymentQueue()
        let sut = AppDelegate(transactionObserver: transactionObserver, paymentQueue: paymentQueue)
        sut.window = UIWindow()
        sut.configureWindow()
        
        return (sut.window?.rootViewController as! UITabBarController, transactionObserver, paymentQueue)
    }
    
    private func launchWithAdControl(file: StaticString = #filePath, line: UInt = #line) throws -> (BannerAdTabBarViewController, IAPTransactionObserver, SKPaymentQueue) {
        let (tabController, transactionObserver, paymentQueue) = launch()
        
        return (try XCTUnwrap(tabController as? BannerAdTabBarViewController, file: file, line: line), transactionObserver, paymentQueue)
    }
    
    private func simulateRestoringCompletedTransactions(observer: IAPTransactionObserver, paymentQueue: SKPaymentQueue) {
        let exp = expectation(description: "wait for transaction")
        
        let originalHandler = observer.onRestorationFinished
        observer.onRestorationFinished = {
            originalHandler?($0)

            exp.fulfill()
        }
        paymentQueue.restoreCompletedTransactions()
        wait(for: [exp], timeout: 5.0)
    }
    
    private func simulateBuying(_ product: SKProduct, observer: IAPTransactionObserver, paymentQueue: SKPaymentQueue) {
        let exp = expectation(description: "wait for transaction")
        
        let originalHandler = observer.onPurchaseProduct
        observer.onPurchaseProduct = {
            originalHandler?($0)
            
            exp.fulfill()
        }
        paymentQueue.add(SKPayment(product: product))
        wait(for: [exp], timeout: 5.0)
    }

    private func cleanPurchaseRecordInApp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
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

private extension IAPTransactionObserver {
    func simulateFailedTransactionWithCancellation(from queue: SKPaymentQueue) {
        paymentQueue(queue, updatedTransactions: [makeFailedTransaction(with: .paymentCancelled)])
    }
    
    func simulateFailedTransaction(with error: SKError.Code, from queue: SKPaymentQueue) {
        paymentQueue(queue, updatedTransactions: [makeFailedTransaction(with: error)])
    }
    
    func simulateRestoreCompletedTransactionFailed(with error: Error, from queue: SKPaymentQueue) {
        paymentQueue(queue, restoreCompletedTransactionsFailedWithError: error)
    }
}
