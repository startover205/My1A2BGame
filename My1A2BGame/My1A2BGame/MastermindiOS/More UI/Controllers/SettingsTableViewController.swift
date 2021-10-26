//
//  SettingsTableViewController.swift
//  EasyTimer
//
//  Created by Ming-Ta Yang on 2019/3/20.
//  Copyright © 2019年 Sam's App Lab. All rights reserved.
//

import UIKit
import MessageUI

let faq = [Question(content: NSLocalizedString("QUESTION_AD_NOT_SHOWING",
                                               tableName: "Localizable",
                                               bundle: .main,
                                               comment: "A question about why an ad is not always showing when the player is out of chances"),
                    answer:  NSLocalizedString("ANSWER_AD_NOT_SHOWING",
                                               tableName: "Localizable",
                                               bundle: .main,
                                               comment: "An answer to why an ad is not always showing when the player is out of chances"))]

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var feedBackCell: UITableViewCell!
    @IBOutlet weak var reviewCell: UITableViewCell!
    @IBOutlet weak var tellFriendsCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? FAQViewController {
            controller.tableModel = faq
        }
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
        var activityItems: [Any] = [NSLocalizedString("Come play \"1A2B Fun!\". Enjoy the simple logic game without taking too much time!", comment: "9th")]
        activityItems.append(Constants.appStoreDownloadUrl)
        
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            controller.popoverPresentationController?.sourceView = tellFriendsCell
            controller.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 22, width: 56, height: 0)
        present(controller, animated: true, completion: nil)
    }
    
    private func presentEmailVC(){
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: NSLocalizedString("No Email Function Available", comment: "6th"), message: NSLocalizedString("We're sorry. Please leave a review in the AppStore instead.", comment: "6th"), preferredStyle: .alert)
            
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
            UIApplication.shared.open(writeReviewURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(writeReviewURL)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
