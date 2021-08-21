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
        let view = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(share))
        return view
    }()
    
    private weak var hostViewController: UIViewController?
    private let guessCount: () -> Int
    private let appDownloadUrl: String
    
    public init(hostViewController: UIViewController, guessCount: @escaping () -> Int, appDownloadUrl: String) {
        self.hostViewController = hostViewController
        self.guessCount = guessCount
        self.appDownloadUrl = appDownloadUrl
    }
    
    @objc func share() {
        guard let hostViewController = hostViewController else { return }
        let guessCount = guessCount()
        
        let format = NSLocalizedString("I won 1A2B Fun! with guessing only %d times! Come challenge me!", comment: "8th")
        var activityItems: [Any] = [String.localizedStringWithFormat(format, guessCount)]
        activityItems.append(appDownloadUrl)
        
        if let snapshotView = hostViewController.view {
            UIGraphicsBeginImageContextWithOptions(snapshotView.bounds.size, false, UIScreen.main.scale)
            snapshotView.drawHierarchy(in: snapshotView.bounds, afterScreenUpdates: true)
            if let screenShotImage = UIGraphicsGetImageFromCurrentImageContext() {
                activityItems.append(screenShotImage)
            }
            UIGraphicsEndImageContext()
        }
        
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.popoverPresentationController?.barButtonItem = view
        hostViewController.present(controller, animated: true)
    }
}
