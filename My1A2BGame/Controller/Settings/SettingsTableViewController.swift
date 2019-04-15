//
//  SettingsTableViewController.swift
//  EasyTimer
//
//  Created by Ming-Ta Yang on 2019/3/20.
//  Copyright © 2019年 Sam's App Lab. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var feedBackCell: UITableViewCell!
    @IBOutlet weak var reviewCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.cellForRow(at: indexPath) {
        case feedBackCell:
            presentEmailVC()
        case reviewCell:
            openAppStoreReview()
        default:
            break
        }
    }
    
    private func presentEmailVC(){
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: NSLocalizedString("No email function available.", comment: ""), message: NSLocalizedString("We're sorry. Please leave a review in the AppStore instead.", comment: ""), preferredStyle: .alert)
            
            let ok = UIAlertAction(title: NSLocalizedString("Here we go!", comment: ""), style: .default) { (_) in
                self.openAppStoreReview()
            }
            
            let cancel = UIAlertAction(title: NSLocalizedString("Maybe later", comment: ""), style: .cancel)
            
            alert.addAction(ok)
            alert.addAction(cancel)
            
            self.present(alert, animated: true)
            return
        }
        
        let deviece = UIDevice.current
        var messageBody = ""
        messageBody.append("\n\n\n\n\n")
        messageBody.append("System version: ")
        messageBody.append(deviece.systemName)
        messageBody.append(" " + deviece.systemVersion + "\n")
        messageBody.append(ErrorManager.loadErrorMessage())
        let composeVC = MFMailComposeViewController()
        
        composeVC.mailComposeDelegate = self
        composeVC.setSubject("[Feed Back]-1A2B Fun!")
        composeVC.setToRecipients(["samsapplab@gmail.com"])
        composeVC.setMessageBody("\(messageBody)", isHTML: false)
        present(composeVC, animated: true) {
        }
    }
    
    private func openAppStoreReview(){
        guard let writeReviewURL = URL(string: Constants.appStoreReviewUrl)
            else { fatalError("Expected a valid URL") }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(writeReviewURL)
        }
    }
}

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
