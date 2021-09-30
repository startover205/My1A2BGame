//
//  ShareViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/8/9.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit

public typealias ActivityViewControllerFactory = (_ items: [Any], _ applicationActivities: [UIActivity]?) -> UIActivityViewController

public final class ShareViewController {
    private(set) lazy var view: UIBarButtonItem = {
        let view = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        return view
    }()
    
    private weak var hostViewController: UIViewController?
    private let items: () -> [Any]
    private let activityViewControllerFactory: ActivityViewControllerFactory
    
    public init(hostViewController: UIViewController, sharing items: @escaping () -> [Any], activityViewControllerFactory: @escaping ActivityViewControllerFactory) {
        self.hostViewController = hostViewController
        self.items = items
        self.activityViewControllerFactory = activityViewControllerFactory
    }
    
    @objc func share() {
        guard let hostViewController = hostViewController else { return }
        
        let controller = activityViewControllerFactory(items(), nil)
        controller.popoverPresentationController?.barButtonItem = view
        hostViewController.present(controller, animated: true)
    }
}
