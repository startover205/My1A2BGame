//
//  IAPCellController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/11/16.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit

final class IAPCellController: NSObject {
    private let product: Product
    private let selection: () -> Void
    
    internal init(product: Product, selection: @escaping () -> Void) {
        self.product = product
        self.selection = selection
    }
}

extension IAPCellController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) 
        
        cell.textLabel?.text = product.name
        cell.detailTextLabel?.text = product.price
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selection()
    }
}
