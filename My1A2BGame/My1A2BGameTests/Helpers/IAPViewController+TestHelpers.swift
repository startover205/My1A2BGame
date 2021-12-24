//
//  IAPViewController+TestHelpers.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/12/24.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit
import My1A2BGame

extension IAPViewController {
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
