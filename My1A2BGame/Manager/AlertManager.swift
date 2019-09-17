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
        var cancelTitle = NSLocalizedString("Cancel", comment: "2nd")
        var actionStyle = UIAlertAction.Style.destructive
        
        switch type {
            /*
             case .deleteTimer:
             alert.title = NSLocalizedString("Are you sure you want to delete this timer?", comment: "")
             alert.message = NSLocalizedString("This is an irreversible action.", comment: "2nd")
             actionTitle = NSLocalizedString("Delete", comment: "2nd")
             case .clearAllTimers:
             alert.title = NSLocalizedString("Are you sure you want to clear the session?", comment: "")
             alert.message = NSLocalizedString("This is an irreversible action.", comment: "2nd")
             actionTitle = NSLocalizedString("Clear All", comment: "2nd")
             case .noEmailFunction:
             alert.title = NSLocalizedString("No email function available.", comment: "")
             alert.message = NSLocalizedString("We're sorry. Please leave a review in the AppStore instead.", comment: "1st")
             actionTitle = NSLocalizedString("Here we go!", comment: "2nd")
             cancelTitle = NSLocalizedString("Maybe Later", comment: "")
             actionStyle = UIAlertAction.Style.default
             case .buyProVersion:
             alert.title = NSLocalizedString("Pro Version", comment: "")
             alert.message = NSLocalizedString("Pro version removes ads and removes limits on max numbers of multiple timers and voice shortcuts.", comment: "1st")
             actionTitle = NSLocalizedString("Purchase", comment: "2nd")
             cancelTitle = NSLocalizedString("Maybe Later", comment: "")
             actionStyle = UIAlertAction.Style.default
             */
        case .giveUp:
            alert.title = NSLocalizedString("Are you sure you want to give up?", comment: "")
            actionTitle = NSLocalizedString("Give Up!", comment: "2nd")
        }
        let ok = UIAlertAction(title: actionTitle, style: actionStyle) { (_) in
            confirmHandler()
        }
        
        let cancel = UIAlertAction(title: cancelTitle, style: .cancel)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert: alert, animated: true)
    }
    
    func showActionAlertWith3rdOption(_ type: Action2Type, confirmHandler: @escaping ()->(), thirdOptionHandler: @escaping ()->()) {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        var actionTitle = NSLocalizedString("Done", comment: "2nd")
        var cancelTitle = NSLocalizedString("Cancel", comment: "2nd")
        let thirdTitle = NSLocalizedString("Never Remind Me Again", comment: "2nd")
        var actionStyle = UIAlertAction.Style.destructive
        let thirdActionStyle = UIAlertAction.Style.destructive
        
        switch type {
            /*
             case .leadToLiteVersion:
             alert.title = NSLocalizedString("We published a New Version", comment: "")
             alert.message = NSLocalizedString("This app won't be updated anymore. Please download the free new version instead.\nYou can unlock the paid features for free in In-App Purchase section. Thank your for the support!", comment: "1st")
             actionTitle = NSLocalizedString("Download Now!", comment: "2nd")
             cancelTitle = NSLocalizedString("Maybe Later", comment: "")
             actionStyle = UIAlertAction.Style.default
             */
        }
        let ok = UIAlertAction(title: actionTitle, style: actionStyle) { (_) in
            confirmHandler()
        }
        
        let cancel = UIAlertAction(title: cancelTitle, style: .cancel)
        
        let thirdOption = UIAlertAction(title: thirdTitle, style: thirdActionStyle) { (_) in
            thirdOptionHandler()
        }
        
        
        alert.addAction(ok)
        alert.addAction(cancel)
        alert.addAction(thirdOption)
        
        present(alert: alert, animated: true)
    }
    
    func showInputAlert(_ type: DataType, defaultText: String? = nil, validityCheck: Bool = true , confirmHandler: @escaping (String?)->() ) {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        
        switch type {
            /*
             
             case .saveSession:
             alert.title = NSLocalizedString("Save current session", comment: "2nd")
             alert.message = NSLocalizedString("There's no need to save it if you only need one session", comment: "2nd")
             alert.addTextField { (textField) in
             textField.clearButtonMode = .whileEditing
             textField.autocapitalizationType = .words
             textField.text = defaultText
             textField.placeholder = NSLocalizedString("Session Name", comment: "2nd")
             textField.addTarget(self, action: #selector(self.checkValidityToEnableDoneBtn(_:)), for: .editingChanged)
             textField.addTarget(self, action: #selector(self.checkValidityToEnableDoneBtn(_:)), for: .editingDidBegin)
             }
             case .addTag:
             alert.title = NSLocalizedString("Add new tag", comment: "2nd")
             alert.addTextField { (textField) in
             textField.clearButtonMode = .whileEditing
             textField.autocapitalizationType = .words
             textField.text = defaultText
             textField.placeholder = NSLocalizedString("Tag Name", comment: "2nd")
             textField.addTarget(self, action: #selector(self.checkValidityToEnableDoneBtn(_:)), for: .editingChanged)
             textField.addTarget(self, action: #selector(self.checkValidityToEnableDoneBtn(_:)), for: .editingDidBegin)
             }
             case .updateSessionName:
             alert.title = NSLocalizedString("Name the session", comment: "2nd")
             alert.addTextField { (textField) in
             textField.clearButtonMode = .whileEditing
             textField.autocapitalizationType = .words
             textField.text = defaultText
             textField.placeholder = NSLocalizedString("Session Name", comment: "2nd")
             }
             */
        }
        
        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (_) in
            confirmHandler(alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces))
        }
        ok.isEnabled = !validityCheck
        self.inputDataAction = ok
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "2nd"), style: .cancel)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert: alert, animated: true)
    }
    
    func showActionSheet(_ type: SheetType, actions: [UIAlertAction], on sourceView: UIView) {
        
        let alert = createActionSheetAlert(type, actions: actions)
        
        alert.popoverPresentationController?.sourceView = sourceView
        alert.popoverPresentationController?.sourceRect = .init(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
        
        present(alert: alert, animated: true)
    }
    
    func showActionSheet(_ type: SheetType, actions: [UIAlertAction],  on barButtonItem: UIBarButtonItem) {
        
        let alert = createActionSheetAlert(type, actions: actions)
        
        alert.popoverPresentationController?.barButtonItem = barButtonItem
        
        present(alert: alert, animated: true)
    }}

// MARK: - Private
private extension AlertManager {
    func present(alert: UIAlertController, animated: Bool){
        UIApplication.topViewController()?.present(alert, animated: animated, completion: nil)
    }
    
    @objc
    func checkValidityToEnableDoneBtn(_ sender: UITextField) {
        inputDataAction?.isEnabled = sender.text?.count ?? 0 > 0
    }
    
    func createActionSheetAlert(_ type: SheetType, actions: [UIAlertAction]) -> UIAlertController{
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        switch type {
            /*
             case .historyItems:
             alert.title = NSLocalizedString("Select Time Interval", comment: "2nd")
             */
        }
        
        for action in actions {
            alert.addAction(action)
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "2nd"), style: .cancel)
        alert.addAction(cancel)
        return alert
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
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
