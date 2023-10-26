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
    
    func test_loadProductCompletion_rendersSuccessfullyLoadedProducts() throws {
        let (sut, loader) = makeSUT()
        let product1 = makeProduct(identifier: "a product identifier", name: "a product name", price: 0.99)
        let product2 = makeProduct(identifier: "another product identifier", name: "another product name", price: 1.99)
        
        sut.loadViewIfNeeded()
        sut.simulateViewAppear()
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
    
    func test_resultMessage_displaysMessageOnEmptyResult() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        sut.simulateViewAppear()
        XCTAssertEqual(sut.resultMessage(), nil)

        loader.completeLoading(with: [], at: 0)
        XCTAssertEqual(sut.resultMessage(), localized("NO_PRODUCT_MESSAGE"))

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.resultMessage(), nil)
        
        loader.completeLoading(with: [makeProduct()], at: 1)
        XCTAssertEqual(sut.resultMessage(), nil)
    }

    func test_purchaseActions_doNotRequestPaymentQueueAndshowMessage_whenPaymentUnavailable() throws {
        let paymentQueue = SKPaymentQueueSpy()
        let (sut, loader) = makeSUT(paymentQueue: paymentQueue, canMakePayment: { false })
        let container = TestingContainerViewController(sut)
        let product = makeProduct()
        
        sut.simulateViewAppear()
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

        sut.simulateViewAppear()
        loader.completeLoading(with: [product])
        sut.simulateOnTapProduct(at: 0)
        
        XCTAssertEqual(paymentQueue.capturedProductID, product.productIdentifier, "Expect purchase made")
        XCTAssertNil(container.presentedViewController, "Expect no message")
    }
    
    func test_loadProductCompletion_dispatchesFromBackgroundToMainQueue() {
        let (sut, loader) = makeSUT()
        let exp = expectation(description: "wait for product loading")
        
        sut.loadViewIfNeeded()
        sut.simulateViewAppear()
        DispatchQueue.global().async {
            loader.completeLoading(with: [])
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.5)
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
        let table = "InAppPurchase"
        let bundle = Bundle(for: ProductPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
    
    private func assertThat(_ sut: IAPViewController, isRendering products: [ProductViewModel], file: StaticString = #filePath, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        
        guard sut.numberOfRenderedProductViews() == products.count else {
            return XCTFail("Expected \(products.count) images, got \(sut.numberOfRenderedProductViews()) instead.", file: file, line: line)
        }
        
        products.enumerated().forEach { index, product in
            assertThat(sut, hasViewConfiguredFor: product, at: index, file: file, line: line)
        }
        
        executeRunLoopToCleanUpReferences()
    }
    
    private func assertThat(_ sut: IAPViewController, hasViewConfiguredFor product: ProductViewModel, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.productView(at: index)
        
        XCTAssertEqual(view?.textLabel?.text, product.name, "Expected name text to be \(String(describing: product.name)) for product view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(view?.detailTextLabel?.text, product.price, "Expected price text to be \(String(describing: product.price)) for product view at index (\(index))", file: file, line: line)
    }
    
    private func executeRunLoopToCleanUpReferences(prolongTime: TimeInterval = 0.0) {
        RunLoop.current.run(until: Date() + prolongTime)
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
        
        convenience init() {
            self.init(makeRequest: { _ in SKProductsRequest() }, getProductIDs: { [] })
        }
        
        override func load(completion: @escaping ([SKProduct]) -> Void) {
            completions.append(completion)
        }
        
        func completeLoading(with products: [SKProduct], at index: Int = 0) {
            completions[index](products)
        }
    }
}

private extension Array where Element == SKProduct {
    func toModels() -> [ProductViewModel] {
        map { ProductViewModel(name: $0.localizedTitle, price: $0.localPrice) }
    }
}
