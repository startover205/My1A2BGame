//
//  IAPUIComposer.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/11/11.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit
import StoreKit

public final class IAPUIComposer {
    private init() {}
    
    public static func iap() -> IAPViewController {
        let iapController = UIStoryboard(name: "More", bundle: .init(for: IAPViewController.self)).instantiateViewController(withIdentifier: "IAPViewController") as! IAPViewController
        iapController.productLoader = MainQueueDispatchIAPLoader()
        
        return iapController
    }
}

public final class MainQueueDispatchIAPLoader: IAPLoader {
    public override func load(productIDs: [String], completion: @escaping ([SKProduct]) -> Void) {
        super.load(productIDs: productIDs) { result in
            if Thread.isMainThread {
                completion(result)
            } else {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}
