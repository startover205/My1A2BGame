//
//  IAPUIIntegrationTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/10/27.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import StoreKitTest
@testable import My1A2BGame

@available(iOS 14.0, *)
class IAPUIIntegrationTests: XCTestCase {
    
    func test_restoreButton_enabled() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.restorePurchaseButton.isEnabled)
    }
    
    func test_restorePurchaseActions_requestPaymentQueueRestore() {
        let paymentQueue = SKPaymentQueueSpy()
        let (sut, _) = makeSUT(paymentQueue: paymentQueue)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(paymentQueue.restoreCallCount, 0, "precondition")
        
        sut.simulateUserInitiatedRestoration()
        XCTAssertEqual(paymentQueue.restoreCallCount, 1, "precondition")
    }
    
    func test_loadingProductIndicator_isVisibleWhileLoadingProduct() throws {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect showing indicator while loading")
        
        loader.completeLoading(with: [], at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect not showing indicator while not loading")
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect showing indicator again while loading")
        
        loader.completeLoading(with: [oneValidProduct()], at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect not showing indicator again while not loading")
    }
    
    func test_loadProductCompletion_rendersSuccessfullyLoadedProducts() throws {
        let (sut, loader) = makeSUT()
        let product1 = makeProduct(identifier: "a product identifier", name: "a product name", price: 0.99)
        let product2 = makeProduct(identifier: "another product identifier", name: "another product name", price: 1.99)
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])

        loader.completeLoading(with: [product1, product2], at: 0)
        assertThat(sut, isRendering: [product1, product2].toModels())
        
        sut.simulateUserInitiatedReload()
        assertThat(sut, isRendering: [product1, product2].toModels())

        loader.completeLoading(with: [product1], at: 1)
        assertThat(sut, isRendering: [product1].toModels())
        
        sut.simulateUserInitiatedReload()
        assertThat(sut, isRendering: [product1].toModels())
        
        loader.completeLoading(with: [], at: 2)
        assertThat(sut, isRendering: [])
    }
    
    func test_loadProductCompletion_doesNotDisplaysMessageOnNonEmptyResult() throws {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [makeProduct()])
        
        XCTAssertEqual(sut.resultMessage(), nil)
    }

    func test_loadProductCompletion_displaysMessageOnEmptyResult() throws {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoading(with: [])
        
        XCTAssertEqual(sut.resultMessage(), localized("NO_PRODUCT_MESSAGE"))
    }
    
    func test_purchaseActions_doNotRequestPaymentQueueAndshowMessage_whenPaymentUnavailable() throws {
        let paymentQueue = SKPaymentQueueSpy()
        let (sut, loader) = makeSUT(paymentQueue: paymentQueue, canMakePayment: { false })
        let container = TestingContainerViewController(sut)
        let product = makeProduct()

        loader.completeLoading(with: [product])

        sut.simulateOnTapProduct(at: 0)
        
        XCTAssertNil(paymentQueue.capturedProductID, "Expect no purchase made")
        let alert = try XCTUnwrap(container.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.title, localized("NO_PAYMENT_MESSAGE"), "alert title")
        XCTAssertEqual(alert.message, localized("NO_PAYMENT_MESSAGE_DETAILED"), "alert title")
        XCTAssertEqual(alert.actions.first?.title, localized("NO_PAYMENT_CONFIRM_ACTION"), "confirm title")

        clearModalPresentationReference(sut)
    }
    
    func test_purchaseActions_requestPaymentQueue_whenPaymentAvailable() throws {
        let paymentQueue = SKPaymentQueueSpy()
        let (sut, loader) = makeSUT(paymentQueue: paymentQueue, canMakePayment: { true })
        let container = TestingContainerViewController(sut)
        let product = makeProduct()

        loader.completeLoading(with: [product])
        sut.simulateOnTapProduct(at: 0)
        
        XCTAssertEqual(paymentQueue.capturedProductID, product.productIdentifier, "Expect purchase made")
        XCTAssertNil(container.presentedViewController, "Expect no message")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(paymentQueue: SKPaymentQueue = .init(), canMakePayment: @escaping () -> Bool = { true }, file: StaticString = #filePath, line: UInt = #line) -> (IAPViewController, IAPProductLoaderSpy) {
        let loader = IAPProductLoaderSpy()
        let sut = IAPUIComposer.iapComposedWith(productLoader: loader, paymentQueue: paymentQueue, canMakePayment: canMakePayment)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Localizable"
        let bundle = Bundle(for: IAPViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
    
    private func assertThat(_ sut: IAPViewController, isRendering products: [My1A2BGame.Product], file: StaticString = #filePath, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        
        guard sut.numberOfRenderedProductViews() == products.count else {
            return XCTFail("Expected \(products.count) images, got \(sut.numberOfRenderedProductViews()) instead.", file: file, line: line)
        }
        
        products.enumerated().forEach { index, product in
            assertThat(sut, hasViewConfiguredFor: product, at: index, file: file, line: line)
        }
        
        executeRunLoopToCleanUpReferences()
    }
    
    private func assertThat(_ sut: IAPViewController, hasViewConfiguredFor product: My1A2BGame.Product, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.productView(at: index)
        
        XCTAssertEqual(view?.textLabel?.text, product.name, "Expected name text to be \(String(describing: product.name)) for product view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(view?.detailTextLabel?.text, product.price, "Expected price text to be \(String(describing: product.price)) for product view at index (\(index))", file: file, line: line)
    }
    
    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date())
    }
    
    private final class SKPaymentQueueSpy: SKPaymentQueue {
        private(set) var restoreCallCount = 0
        private(set) var capturedProductID: String?
        
        override func restoreCompletedTransactions() {
            restoreCallCount += 1
        }
        
        override func add(_ payment: SKPayment) {
            capturedProductID = payment.productIdentifier
        }
    }
    
    private final class IAPProductLoaderSpy: IAPProductLoader {
        private var completions = [([SKProduct]) -> Void]()
        
        override func load(productIDs: [String], completion: @escaping ([SKProduct]) -> Void) {
            completions.append(completion)
        }
        
        func completeLoading(with products: [SKProduct], at index: Int = 0) {
            completions[index](products)
        }
    }
}

private extension IAPViewController {
    func simulateUserInitiatedReload() {
        refreshControl?.sendActions(for: .valueChanged)
    }
    
    func simulateOnTapProduct(at row: Int) {
        tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: row, section: productSection))
    }
    
    func simulateUserInitiatedRestoration() {
        restorePurchaseButton.simulateTap()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }
    
    func resultMessage() -> String? {
        (tableView.tableHeaderView as? UILabel)?.text
    }
    
    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }
    
    func cell(row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    func numberOfRenderedProductViews() -> Int {
        numberOfRows(in: productSection)
    }
    
    func productView(at row: Int) -> UITableViewCell? {
        cell(row: row, section: productSection)
    }
    
    private var productSection: Int { 0 }
}

private extension Array where Element == SKProduct {
    func toModels() -> [My1A2BGame.Product] {
        map { Product(name: $0.localizedTitle, price: $0.localPrice) }
    }
}
