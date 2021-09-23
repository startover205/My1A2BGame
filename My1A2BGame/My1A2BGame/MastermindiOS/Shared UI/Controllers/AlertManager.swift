//
//  AlertManager.swift
//  EasyTimer
//
//  Created by Ming-Ta Yang on 2019/5/8.
//  Copyright © 2019 Sam's App Lab. All rights reserved.
//

import UIKit

class AlertManager: NSObject {
    static var shared = AlertManager()
    weak var inputDataAction: UIAlertAction?
    
    private override init(){}
    
    enum ConfirmType {
        case helperInfo
    }
    
    enum ActionType {
        case giveUp
    }
    
    enum Action2Type {
    }
    
    enum DataType {
    }
    
    enum SheetType {
    }
    
    func showConfirmAlert(_ type: ConfirmType, errorMessage: String? = nil, oKcompletion: (()->())? = nil){
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        
        switch type {
        case .helperInfo:
            alert.title = NSLocalizedString("Helper Area", comment: "")
            alert.message = NSLocalizedString("You can filter out numbers however you want in this area.", comment: "")
        }
        
        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default){ _ in
            oKcompletion?()
        }
        
        alert.addAction(ok)
        
        present(alert: alert, animated: true)
    }
    
    func showActionAlert(_ type: ActionType, confirmHandler: @escaping ()->()) {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        var actionTitle = NSLocalizedString("Done", comment: "2nd")
        let cancelTitle = NSLocalizedString("Cancel", comment: "2nd")
        let actionStyle = UIAlertAction.Style.destructive
        
        switch type {
        case .giveUp:
            alert.title = NSLocalizedString("GAME_GIVE_UP_ALERT_TITLE", comment: "")
            actionTitle = NSLocalizedString("GAME_GIVE_UP_ALERT_CONFIRM_TITLE", comment: "2nd")
        }
        let ok = UIAlertAction(title: actionTitle, style: actionStyle) { (_) in
            confirmHandler()
        }
        
        let cancel = UIAlertAction(title: cancelTitle, style: .cancel)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert: alert, animated: true)
    }
}

// MARK: - Private
private extension AlertManager {
    func present(alert: UIAlertController, animated: Bool){
        UIApplication.topViewController()?.present(alert, animated: animated, completion: nil)
    }
    
    @objc
    func checkValidityToEnableDoneBtn(_ sender: UITextField) {
        inputDataAction?.isEnabled = sender.text?.count ?? 0 > 0
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
