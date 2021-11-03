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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> IAPViewController {
        let sut = UIStoryboard(name: "More", bundle: .init(for: IAPViewController.self)).instantiateViewController(withIdentifier: "IAPViewController") as! IAPViewController
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
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

private extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}

extension IAPTableViewCell {
    var nameText: String? {
        productNameLabel.text
    }
    
    var priceText: String? {
        productPriceLabel.text
    }
}
