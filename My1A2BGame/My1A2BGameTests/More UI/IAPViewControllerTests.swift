//
//  IAPViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/10/27.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import StoreKitTest
@testable import My1A2BGame

private struct Product {
    let name: String
    let price: String
}

@available(iOS 14.0, *)
class IAPViewControllerTests: XCTestCase {
    
    override func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    func test_viewDidLoad_configuresRestorePurchaseButton() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.restorePurchaseButton.isEnabled)
    }
    
    func test_loadingProductIndicator_isVisibleWhileLoadingProduct() throws {
        let sut = makeSUT()
        let session = try SKTestSession(configurationFileNamed: "NonConsumable")
        session.disableDialogs = true
        session.clearTransactions()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        let exp = expectation(description: "wait for product loading")
        exp.isInverted = true
        wait(for: [exp], timeout: 1)
        
        sut.loadViewIfNeeded()
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_loadProductCompletion_rendersSuccessfullyLoadedProducts() throws {
        let sut = makeSUT()
        let product = Product(name: "Remove Bottom Ad", price: "$0.99")
        let session = try SKTestSession(configurationFileNamed: "NonConsumable")
        session.disableDialogs = true
        session.clearTransactions()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        let exp = expectation(description: "wait for product loading")
        exp.isInverted = true
        wait(for: [exp], timeout: 1)
        
        assertThat(sut, isRendering: [product])
    }
    
    func test_loadProductCompletion_displaysMessageOnEmptyResult() throws {
        let sut = makeSUT()
        let session = try SKTestSession(configurationFileNamed: "NonConsumable")
        session.disableDialogs = true
        session.clearTransactions()
        let container = TestingContainerViewController(sut)
        
        let exp = expectation(description: "wait for product loading")
        exp.isInverted = true
        wait(for: [exp], timeout: 1)
        
        sut.simulateOnTapProduct(at: 0)
        
        let exp2 = expectation(description: "wait for product purchase")
        exp2.isInverted = true
        wait(for: [exp2], timeout: 1)
        
        let alert = try XCTUnwrap(container.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.title, localized("NO_PRODUCT_MESSAGE"), "alert title")
        XCTAssertEqual(alert.actions.first?.title, localized("NO_PRODUCT_CONFIRM_ACTION"), "confirm title")
        
        clearModalPresentationReference(sut)
    }
    
    func test_buyProduct_refreshProductList() throws {
        let sut = makeSUT()
        let product = Product(name: "Remove Bottom Ad", price: "$0.99")
        let session = try SKTestSession(configurationFileNamed: "NonConsumable")
        session.disableDialogs = true
        session.clearTransactions()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        let exp = expectation(description: "wait for product loading")
        exp.isInverted = true
        wait(for: [exp], timeout: 1)
        
        assertThat(sut, isRendering: [product])
        
        sut.simulateOnTapProduct(at: 0)
        
        let exp2 = expectation(description: "wait for product purchase")
        exp2.isInverted = true
        wait(for: [exp2], timeout: 1)
        
        assertThat(sut, isRendering: [])
    }
    
    func test_restorePurchase_refreshesProductList() throws {
        let sut = makeSUT()
        let anotherSut = makeSUT()
        let product = Product(name: "Remove Bottom Ad", price: "$0.99")
        let session = try SKTestSession(configurationFileNamed: "NonConsumable")
        session.disableDialogs = true
        session.clearTransactions()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        let exp = expectation(description: "wait for product loading")
        exp.isInverted = true
        wait(for: [exp], timeout: 1)
        
        assertThat(sut, isRendering: [product])
        
        sut.simulateOnTapProduct(at: 0)
        
        let exp2 = expectation(description: "wait for product purchase")
        exp2.isInverted = true
        wait(for: [exp2], timeout: 1)
        
        clearPurchaseRecordsInDevice()
        
        anotherSut.loadViewIfNeeded()
        assertThat(anotherSut, isRendering: [])

        let exp3 = expectation(description: "wait for product loading")
        exp3.isInverted = true
        wait(for: [exp3], timeout: 1)
        
        assertThat(anotherSut, isRendering: [product])
        
        anotherSut.simulateRestoreProduct()
        
        let exp4 = expectation(description: "wait for product restore")
        exp4.isInverted = true
        wait(for: [exp4], timeout: 1)
        
        assertThat(anotherSut, isRendering: [])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> IAPViewController {
        let sut = IAPUIComposer.iap()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func clearPurchaseRecordsInDevice() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
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
    
    private func assertThat(_ sut: IAPViewController, isRendering products: [Product], file: StaticString = #filePath, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        
        guard sut.numberOfRenderedProductViews() == products.count else {
            return XCTFail("Expected \(products.count) images, got \(sut.numberOfRenderedProductViews()) instead.", file: file, line: line)
        }
        
        products.enumerated().forEach { index, product in
            assertThat(sut, hasViewConfiguredFor: product, at: index, file: file, line: line)
        }
        
        executeRunLoopToCleanUpReferences()
    }
    
    private func assertThat(_ sut: IAPViewController, hasViewConfiguredFor product: Product, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
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
}

private extension IAPViewController {
    func simulateOnTapProduct(at row: Int) {
        tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: row, section: productSection))
    }
    
    func simulateRestoreProduct() {
        restorePurchaseButton.simulateTap()
    }
    
    var isShowingLoadingIndicator: Bool {
        guard let indicator = activityIndicator else { return false }
        
        return view.subviews.contains(indicator) && indicator.isAnimating
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

extension IAPTableViewCell {
    var nameText: String? {
        productNameLabel.text
    }
    
    var priceText: String? {
        productPriceLabel.text
    }
}
