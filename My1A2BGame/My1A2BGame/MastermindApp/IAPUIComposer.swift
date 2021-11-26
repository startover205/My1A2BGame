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
    
    public static func iapComposedWith(productLoader: IAPLoader) -> IAPViewController {
        let iapController = UIStoryboard(name: "More", bundle: .init(for: IAPViewController.self)).instantiateViewController(withIdentifier: "IAPViewController") as! IAPViewController
        iapController.productLoader = productLoader
        
        return iapController
    }
}
