//
//  ShareViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/8/9.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit

public final class ShareViewController {
    private(set) lazy var view: UIBarButtonItem = {
        let view = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        return view
    }()
    
    private weak var hostViewController: UIViewController?
    private let items: () -> [Any]
    
    public init(hostViewController: UIViewController, sharing items: @escaping () -> [Any]) {
        self.hostViewController = hostViewController
        self.items = items
    }
    
    @objc func share() {
        guard let hostViewController = hostViewController else { return }

        let controller = UIActivityViewController(activityItems: items(), applicationActivities: nil)
        controller.popoverPresentationController?.barButtonItem = view
        hostViewController.present(controller, animated: true)
    }
}
