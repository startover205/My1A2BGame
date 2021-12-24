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
        XCTAssertEqual(alert.title,  localized("PURCHASE_ERROR"), "alert title")
        XCTAssertEqual(alert.message, SKError(.unknown).localizedDescription, "alert message")
        XCTAssertEqual(alert.actions.first?.title, localized("MESSAGE_DISMISS_ACTION"), "confirm title")
    }
    
    func test_iap_handlePurchase_showsMessageOnPurchasingUnknownProduct() throws {
        let (tabController, transactionObserver, paymentQueue) = launch()
        let unknownProduct = unknownProdcut()
        
        try createLocalTestSession("Unknown")
        simulateBuying(unknownProduct, observer: transactionObserver, paymentQueue: paymentQueue)
        
        let alert = try XCTUnwrap(tabController.presentedViewController as? UIAlertController)
        let format = localized("UNKNOWN_PRODUCT_MESSAGE_FOR_%@")
        XCTAssertEqual(alert.title, String.localizedStringWithFormat(format, unknownProduct.productIdentifier), "alert title")
        XCTAssertEqual(alert.actions.first?.title, localized("MESSAGE_DISMISS_ACTION"), "confirm title")
    }

    func test_iap_restoreCompletedTransactions_showsMessageOnRestorationError() throws {
        let (tabController, transactionObserver, paymentQueue) = launch()
        let restorationError = anyNSError()

        transactionObserver.simulateRestoreCompletedTransactionFailed(with: restorationError, from: paymentQueue)

        let alert = try XCTUnwrap(tabController.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.title, localized("RESTORE_PURCHASE_ERROR"), "alert title")
        XCTAssertEqual(alert.message, restorationError.localizedDescription, "alert message")
        XCTAssertEqual(alert.actions.first?.title, localized("MESSAGE_DISMISS_ACTION"), "confirm title")
    }

    func test_iap_restoreCompletedTransactions_showsMessageOnSuccessfulEmptyRestoration() throws {
        let (tabController, transactionObserver, paymentQueue) = launch()

        try createLocalTestSession()
        simulateRestoringCompletedTransactions(observer: transactionObserver, paymentQueue: paymentQueue)

        let alert = try XCTUnwrap(tabController.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.title, localized("NO_RESTORABLE_PRODUCT_MESSAGE"), "alert title")
        XCTAssertEqual(alert.actions.first?.title, localized("MESSAGE_DISMISS_ACTION"), "confirm title")
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
        XCTAssertEqual(alert.title, localized("RESTORE_PURCHASE_SUCCESS"), "alert title")
        XCTAssertEqual(alert.actions.first?.title, localized("MESSAGE_DISMISS_ACTION"), "confirm title")
    }
    
    // MARK: - Product

    func test_iap_handlePurchase_removesBottomAdOnSuccessfulPurchaseOrRestoration() throws {
        let userDefaults = InMemoryUserDefaults()
        var (tabController, transactionObserver, paymentQueue) = launch(userDefaults: userDefaults)
        let removeBottomAdProduct = removeBottomAdProduct()
        tabController.simulateViewAppear()

        assertNonZeroInsetsForAllChildController(of: tabController)
        XCTAssertEqual(tabController.adView()?.alpha, 1, "Expect showing Ad before purchase")
        
        try createLocalTestSession()
        simulateBuying(removeBottomAdProduct, observer: transactionObserver, paymentQueue: paymentQueue)
        assertZeroInsetsForAllChildController(of: tabController)
        XCTAssertEqual(tabController.adView()?.alpha, 0, "Expect hiding Ad after purchase")

        (tabController, transactionObserver, paymentQueue) = launch(userDefaults: userDefaults)
        tabController.simulateViewAppear()
        assertZeroInsetsForAllChildController(of: tabController)
        XCTAssertNil(tabController.adView(), "Expect no Ad loaded since now the Ad is removed")

        userDefaults.cleanPurchaseRecordInApp()
        simulateRestoringCompletedTransactions(observer: transactionObserver, paymentQueue: paymentQueue)

        (tabController, transactionObserver, paymentQueue) = launch(userDefaults: userDefaults)
        tabController.simulateViewAppear()
        assertZeroInsetsForAllChildController(of: tabController)
        XCTAssertNil(tabController.adView(), "Expect no Ad loaded after purhcase restored")
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
    
    private func launch(userDefaults: UserDefaults = InMemoryUserDefaults(), productLoader: IAPProductLoader = IAPProductLoaderSpy()) -> (UITabBarController, IAPTransactionObserver, SKPaymentQueue) {
        let transactionObserver = IAPTransactionObserver()
        let paymentQueue = SKPaymentQueue()
        let sut = AppDelegate(userDefaults: userDefaults, transactionObserver: transactionObserver, paymentQueue: paymentQueue, productLoader: productLoader)
        sut.window = UIWindow()
        sut.configureWindow()
        
        return (sut.window?.rootViewController as! UITabBarController, transactionObserver, paymentQueue)
    }
    
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Localizable"
        let bundle = Bundle.main
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
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
    
    private final class IAPProductLoaderSpy: IAPProductLoader {
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

private func removeBottomAdProduct() -> SKProduct {
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
