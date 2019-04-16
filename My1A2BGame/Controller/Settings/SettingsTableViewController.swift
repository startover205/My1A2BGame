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
    @IBOutlet weak var tellFriendsCell: UITableViewCell!
    
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
        case tellFriendsCell:
            presentShareAlert()
        default:
            break
        }
    }
}

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

// MARK: - Private
private extension SettingsTableViewController {
    func presentShareAlert(){
        var activityItems: [Any] = [NSLocalizedString("來玩「1A2B Fun!」吧！不需花大量時間，就能享受動腦的樂趣！", comment: "9th")]
        activityItems.append(Constants.appStoreDownloadUrl)
        
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }
    
    private func presentEmailVC(){
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: NSLocalizedString("No email function available.", comment: "6th"), message: NSLocalizedString("We're sorry. Please leave a review in the AppStore instead.", comment: "6th"), preferredStyle: .alert)
            
            let ok = UIAlertAction(title: NSLocalizedString("Here we go!", comment: "6th"), style: .default) { (_) in
                self.openAppStoreReview()
            }
            
            let cancel = UIAlertAction(title: NSLocalizedString("Maybe later", comment: "6th"), style: .cancel)
            
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
