//
//  MoreViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/11/8.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame

class MoreViewControllerTests: XCTestCase {
    
    func test_viewDidLoad_rendersEmptyListOnEmptyItems() {
        let sut = makeSUT(items: [])
        
        sut.loadViewIfNeeded()
        
        assertThat(sut, isRendering: [])
    }
    
    func test_viewDidLoad_rendersItemsOnNonEmptyItems() {
        let item1 = makeItem(name: "a name", image: UIImage.make(withColor: .red))
        let item2 = makeItem(name: "another name", image: UIImage.make(withColor: .green))
        let sut = makeSUT(items: [item1, item2])
        
        sut.loadViewIfNeeded()
        
        assertThat(sut, isRendering: [item1, item2])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(items: [MoreItem], file: StaticString = #filePath, line: UInt = #line) -> MoreViewController {
        let sut = UIStoryboard(name: "More", bundle: Bundle(for: MoreViewController.self)).instantiateViewController(withIdentifier: "MoreViewController") as! MoreViewController
        
        sut.tableModel = items
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func assertThat(_ sut: MoreViewController, isRendering items: [MoreItem], file: StaticString = #filePath, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        
        guard sut.numberOfRenderedItemViews() == items.count else {
            return XCTFail("Expected \(items.count) items, got \(sut.numberOfRenderedItemViews()) instead.", file: file, line: line)
        }
        
        items.enumerated().forEach { index, item in
            assertThat(sut, hasViewConfiguredFor: item, at: index, file: file, line: line)
        }
        
        executeRunLoopToCleanUpReferences()
    }
    
    private func assertThat(_ sut: MoreViewController, hasViewConfiguredFor item: MoreItem, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let cell = sut.itemView(at: index)
        
        XCTAssertEqual(cell?.textLabel?.text, item.name, "Expected name text to be \(String(describing: item.name)) for item view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell?.imageView?.image?.pngData(), item.image.pngData(), "Expected image to be \(String(describing: item.image)) for item view at index (\(index))", file: file, line: line)
    }
    
    private func makeItem(name: String, image: UIImage) -> MoreItem {
        .init(name: name, image: image, selection: { _ in })
    }
}

private func executeRunLoopToCleanUpReferences() {
    RunLoop.current.run(until: Date())
}

private extension MoreViewController {
    func simulateOnTapItem(at row: Int) {
        tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: row, section: itemSection))
    }
    
    private func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }
    
    private func cell(row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    func numberOfRenderedItemViews() -> Int {
        numberOfRows(in: itemSection)
    }
    
    func itemView(at row: Int) -> UITableViewCell? {
        cell(row: row, section: itemSection)
    }
    
    private var itemSection: Int { 0 }
}

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
