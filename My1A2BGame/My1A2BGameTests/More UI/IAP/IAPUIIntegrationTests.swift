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

    func test_loadProductCompletion_displaysMessageOnEmptyResult() throws {
        let (sut, loader) = makeSUT()
        let container = TestingContainerViewController(sut)

        loader.completeLoading(with: [])

        let alert = try XCTUnwrap(container.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.title, localized("NO_PRODUCT_MESSAGE"), "alert title")
        XCTAssertEqual(alert.actions.first?.title, localized("NO_PRODUCT_CONFIRM_ACTION"), "confirm title")

        clearModalPresentationReference(sut)
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (IAPViewController, IAPProductLoaderSpy) {
        let loader = IAPProductLoaderSpy()
        let sut = IAPUIComposer.iapComposedWith(productLoader: loader)
        
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
        
        guard let cell = view as? IAPTableViewCell else {
            return XCTFail("Expected \(IAPTableViewCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.nameText, product.name, "Expected name text to be \(String(describing: product.name)) for product view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.priceText, product.price, "Expected price text to be \(String(describing: product.price)) for product view at index (\(index))", file: file, line: line)
    }
    
    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date())
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
    
    func simulateRestoreProduct() {
        restorePurchaseButton.simulateTap()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
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

private extension IAPTableViewCell {
    var nameText: String? {
        productNameLabel.text
    }
    
    var priceText: String? {
        productPriceLabel.text
    }
}

private extension Array where Element == SKProduct {
    func toModels() -> [My1A2BGame.Product] {
        map { Product(name: $0.localizedTitle, price: $0.localPrice) }
    }
}
