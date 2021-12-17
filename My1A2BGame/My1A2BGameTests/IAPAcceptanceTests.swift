//
//  IAPAcceptanceTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/11/25.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import StoreKitTest
import GoogleMobileAds
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
        simulateBuying(oneValidProduct(), observer: transactionObserver, paymentQueue: paymentQueue)
        
        let exp = expectation(description: "wait for finishing transaction")
        exp.isInverted = true
        wait(for: [exp], timeout: 0.1)
        
        simulateRestoringCompletedTransactions(observer: transactionObserver, paymentQueue: paymentQueue)
        
        let alert = try XCTUnwrap(tabController.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.title, "Successfully Restored Purchase", "alert title")
        XCTAssertEqual(alert.message, "Certain content will only be available after restarting the app.", "alert message")
        XCTAssertEqual(alert.actions.first?.title, "Confirm", "confirm title")
    }
    
    // MARK: - Product

    func test_iap_handlePurchase_removesBottomADOnSuccessfulPurchaseOrRestoration() throws {
        let userDefaults = InMemoryUserDefaults()
        var (tabController, transactionObserver, paymentQueue) = launch(userDefaults: userDefaults)
        let removeBottomADProduct = removeBottomADProduct()
        tabController.simulateViewAppear()

        assertNonZeroInsetsForAllChildController(of: tabController)
        XCTAssertEqual(tabController.adView()?.alpha, 1, "Expect showing AD before purchase")
        
        try createLocalTestSession()
        simulateBuying(removeBottomADProduct, observer: transactionObserver, paymentQueue: paymentQueue)
        assertZeroInsetsForAllChildController(of: tabController)
        XCTAssertEqual(tabController.adView()?.alpha, 0, "Expect hiding AD after purchase")

        (tabController, transactionObserver, paymentQueue) = launch(userDefaults: userDefaults)
        tabController.simulateViewAppear()
        assertZeroInsetsForAllChildController(of: tabController)
        XCTAssertNil(tabController.adView(), "Expect no AD loaded since now the AD is removed")

        userDefaults.cleanPurchaseRecordInApp()
        simulateRestoringCompletedTransactions(observer: transactionObserver, paymentQueue: paymentQueue)

        (tabController, transactionObserver, paymentQueue) = launch(userDefaults: userDefaults)
        tabController.simulateViewAppear()
        assertZeroInsetsForAllChildController(of: tabController)
        XCTAssertNil(tabController.adView(), "Expect no AD loaded after purhcase restored")
    }
    
    private func assertZeroInsetsForAllChildController(of tabController: UITabBarController, file: StaticString = #filePath, line: UInt = #line) {
        
        for (index, controller) in tabController.children.enumerated() {
            XCTAssertEqual(controller.additionalSafeAreaInsets, .zero, "Expect controller at \(index) to be zero", file: file, line: line)
        }
    }
    
    private func assertNonZeroInsetsForAllChildController(of tabController: UITabBarController, file: StaticString = #filePath, line: UInt = #line) {
        
        for (index, controller) in tabController.children.enumerated() {
            XCTAssertNotEqual(controller.additionalSafeAreaInsets, .zero, "Expect controller at \(index) to be non-zero", file: file, line: line)
        }
    }
    
    // MARK: - Composable View
    
    func test_handlePurchase_refreshesIAPViewOnPurchaseOrRestoreProducts() throws {
        let loader = IAPProductLoaderSpy()
        let (tabController, transactionObserver, paymentQueue) = launch(productLoader: loader)
        try createLocalTestSession()
        let _ = tabController.iapController()
        
        XCTAssertEqual(loader.loadCallCount, 1, "Expect refresh after view load")

        simulateBuying(oneValidProduct(), observer: transactionObserver, paymentQueue: paymentQueue)

        XCTAssertEqual(loader.loadCallCount, 2, "Expect refresh after product purchase")

        let exp = expectation(description: "wait for purchased transaction to be finished")
        exp.isInverted = true
        wait(for: [exp], timeout: 0.1)
        
        simulateRestoringCompletedTransactions(observer: transactionObserver, paymentQueue: paymentQueue)

        XCTAssertEqual(loader.loadCallCount, 3, "Expect refresh after product restoration")
    }
    
    // MARK: - Helpers
    
    private func launch(userDefaults: UserDefaults = InMemoryUserDefaults(), productLoader: ProductLoader = IAPProductLoaderSpy()) -> (UITabBarController, IAPTransactionObserver, SKPaymentQueue) {
        let transactionObserver = IAPTransactionObserver()
        let paymentQueue = SKPaymentQueue()
        let sut = AppDelegate(userDefaults: userDefaults, transactionObserver: transactionObserver, paymentQueue: paymentQueue, productLoader: productLoader)
        sut.window = UIWindow()
        sut.configureWindow()
        
        return (sut.window?.rootViewController as! UITabBarController, transactionObserver, paymentQueue)
    }
    
    private final class IAPProductLoaderSpy: ProductLoader {
        private(set) var loadCallCount = 0
        
        convenience init() {
            self.init(makeRequest: { _ in SKProductsRequest() }, getProductIDs: { [] })
        }
        
        override func load(completion: @escaping ([SKProduct]) -> Void) {
            loadCallCount += 1
            completion([])
        }
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

private extension UITabBarController {
    private func selectTab<T>(at index: Int) -> T {
        selectedIndex = index
        
        RunLoop.current.run(until: Date())
        
        let nav = viewControllers?[index] as? UINavigationController
        return nav?.topViewController as! T
    }
    
    func moreController() -> MoreViewController { selectTab(at: 3) }
    
    func iapController() -> IAPViewController {
        let moreController = moreController()
        moreController.tableView(moreController.tableView, didSelectRowAt: [0, 1])
        
        RunLoop.current.run(until: Date())
        
        return (moreController.navigationController?.topViewController as! IAPViewController)
    }
    
    func adView() -> UIView? {
        for view in tabBar.subviews {
            if view is GADBannerView { return view }
        }
        return nil
    }
}

private extension InMemoryUserDefaults {
    func cleanPurchaseRecordInApp() {
        clearAllValues()
    }
}
