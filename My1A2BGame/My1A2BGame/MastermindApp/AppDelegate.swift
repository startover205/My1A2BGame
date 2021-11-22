//
//  AppDelegate.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2018/5/30.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import UIKit
import StoreKit
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import Mastermind
import MastermindiOS
import MessageUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var reachability = Reachability.forInternetConnection()
    
    private lazy var basicRecordLoader: RecordLoader = {
        let modelName = "Model"
        let store = try! CoreDataRecordStore<Winner>(
            storeURL: storeURL(for: modelName),
            modelName: modelName)
        return LocalRecordLoader(store: store)
    }()
    
    private lazy var advancedRecordLoader: RecordLoader = {
        let modelName = "ModelAdvanced"
        let store = try! CoreDataRecordStore<AdvancedWinner>(
            storeURL: storeURL(for: modelName),
            modelName: modelName)
        return LocalRecordLoader(store: store)
    }()
    
    private lazy var tabController = BannerAdTabBarViewController(isBottomADRemoved: { AdControl.isBottomAdRemoved(userDefaults: .standard) })
    private lazy var basicGameNavigationController = UINavigationController()
    private lazy var advancedGameNavigationController = UINavigationController()
    private lazy var moreNavigationController = UINavigationController()

    private let basicGameVersion: GameVersion = .basic
    private let advancedGameVersion: GameVersion = .advanced
    
    private lazy var secretGenerator: (Int) -> DigitSecret = RandomDigitSecretGenerator.generate(digitCount:)
    
    private lazy var rewardAdLoader: RewardAdLoader = GoogleRewardAdManager.shared
    
    private lazy var requestReview: () -> Void = {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            SKStoreReviewController.requestReview()
        }
    }
    
    private lazy var userDefaults: UserDefaults = .standard
    
    private lazy var appReviewController: AppReviewController? = {
        guard let appVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String else { return nil }
        return CounterAppReviewController(
            userDefaults: userDefaults,
            askForReview: requestReview,
            targetProcessCompletedCount: 3,
            appVersion: appVersion)
    }()
    
    convenience init(userDefaults: UserDefaults, secretGenerator: @escaping (Int) -> DigitSecret, rewardAdLoader: RewardAdLoader, requestReview: @escaping () -> Void) {
        self.init()
        
        self.userDefaults = userDefaults
        self.secretGenerator = secretGenerator
        self.rewardAdLoader = rewardAdLoader
        self.requestReview = requestReview
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        SKPaymentQueue.default().add(IAPTransactionObserver.shared)
        
        // 設定廣告
        if #available(iOS 14, *) {
            // requestIDFA
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                
                // setup ad
                GADMobileAds.sharedInstance().start(completionHandler: nil)
                
                GoogleRewardAdManager.shared.begin()
                
            })
        } else {
            GADMobileAds.sharedInstance().start(completionHandler: nil)
            
            GoogleRewardAdManager.shared.begin()
        }
        
        window = UIWindow()
        configureWindow()
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(IAPTransactionObserver.shared)
    }
    
    func configureWindow() {
        window?.rootViewController = makeTabController()
        
        window?.makeKeyAndVisible()
        
        startNewBasicGame()
        
        startNewAdvancedGame()
        
        configureIAPTransactionObserver()
    }
    
    private func configureIAPTransactionObserver() {
        IAPTransactionObserver.shared.restorationDelegate = RestorationDelegateAdapter(hostViewController: tabController)
    }
    
    private final class RestorationDelegateAdapter: IAPRestorationDelegate {
        init(hostViewController: UIViewController) {
            self.hostViewController = hostViewController
        }
        
        weak var hostViewController: UIViewController?
        
        func restorationFinished(with error: Error) {
            let alert = UIAlertController(title: NSLocalizedString("Failed to Restore Purchase", comment: "3nd"), message: error.localizedDescription, preferredStyle: .alert)
            
            let ok = UIAlertAction(title: NSLocalizedString("Confirm", comment: "3nd"), style: .default)
            
            alert.addAction(ok)
            
            hostViewController?.showDetailViewController(alert, sender: self)
        }
        
        func restorationFinished(hasRestorableContent: Bool) {
            let (title, message) = hasRestorableContent ? (NSLocalizedString("Successfully Restored Purchase", comment: "3nd"), NSLocalizedString("Certain content will only be available after restarting the app.", comment: "3nd")) : (NSLocalizedString("No Restorable Products", comment: "3nd"), nil)
        
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let ok = UIAlertAction(title: NSLocalizedString("Confirm", comment: "3nd"), style: .default)

            alert.addAction(ok)

            hostViewController?.showDetailViewController(alert, sender: self)
        }
    }
    
    private func makeTabController() -> UITabBarController {
        let tabConfigurations: [(title: String, imageName: String)] = [
            (basicGameVersion.title, "baseline_1A2B_24px"),
            (advancedGameVersion.title, "advanced_24px"),
            ("Rank", "baseline_format_list_numbered_black_24pt"),
            ("More", "baseline_settings_black_24pt"),
        ]
        let rankNav = UINavigationController(rootViewController: RankUIComposer.rankComposedWith(ranks: [
                                                                                                    Rank(title: "Basic",
                                                                                                         loader: basicRecordLoader),
                                                                                                    Rank(title: "Advanced",
                                                                                                         loader: advancedRecordLoader)],
                                                                                                 alertHost: tabController))
        
        tabController.setViewControllers([basicGameNavigationController, advancedGameNavigationController, rankNav, makeMoreVC()], animated: false)
        
        tabController.tabBar.items!.enumerated().forEach { index, item in
            item.title = tabConfigurations[index].title
            item.image = UIImage(named: tabConfigurations[index].imageName)
        }
        
        return tabController
    }
}

private extension AppDelegate {
    private func startNewBasicGame() {
        let gameVersion = basicGameVersion
        let secret = secretGenerator(gameVersion.digitCount)
        let gameController = makeGameController(
            navigationController: basicGameNavigationController,
            secret: secret,
            gameVersion: gameVersion,
            recordLoader: basicRecordLoader,
            onRestart: startNewBasicGame)
        
        basicGameNavigationController.setViewControllers([gameController], animated: false)
    }
    
    private func startNewAdvancedGame() {
        let gameVersion = advancedGameVersion
        let secret = secretGenerator(gameVersion.digitCount)
        let gameController = makeGameController(
            navigationController: advancedGameNavigationController,
            secret: secret,
            gameVersion: gameVersion,
            recordLoader: advancedRecordLoader,
            onRestart: startNewAdvancedGame)
        
        advancedGameNavigationController.setViewControllers([gameController], animated: false)
    }
    
    private func makeGameController(navigationController: UINavigationController, secret: DigitSecret, gameVersion: GameVersion, recordLoader: RecordLoader, onRestart: @escaping () -> Void) -> GuessNumberViewController {
        let rewardAdViewController = RewardAdViewController(loader: rewardAdLoader, rewardChanceCount: Constants.adGrantChances, hostViewController: tabController)
        let controller = GameUIComposer.gameComposedWith(
            title: gameVersion.title,
            gameVersion: gameVersion,
            userDefaults: userDefaults,
            secret: secret,
            delegate: rewardAdViewController,
            onWin: { score in
                let winController = WinUIComposer.winComposedWith(score: score, digitCount: gameVersion.digitCount, recordLoader: recordLoader, appDownloadURL: Constants.appStoreDownloadUrl)
                navigationController.pushViewController(winController, animated: true)
                
                self.appReviewController?.askForReviewIfAppropriate()
            },
            onLose: {
                navigationController.pushViewController(LoseUIComposer.loseScene(), animated: true)
            },
            onRestart: onRestart)
        
        return controller
    }
    
    private func storeURL(for modelName: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(modelName + ".sqlite")
    }
}

private extension AppDelegate {
     func makeMoreVC() -> UIViewController {
        let moreController = UIStoryboard(name: "More", bundle: .init(for: MoreViewController.self)).instantiateViewController(withIdentifier: "MoreViewController") as! MoreViewController
        moreController.title = "More"
        moreController.tableModel = [
            .init(name: "Q & A", image: #imageLiteral(resourceName: "baseline_help_black_24pt"), selection: { _ in self.selectFAQ() }),
            .init(name: "In-App Purchase", image: #imageLiteral(resourceName: "baseline_shopping_basket_black_24pt"), selection: { _ in self.selectIAP() }),
            .init(name: "Feedback & Bug Report", image: #imageLiteral(resourceName: "baseline_bug_report_black_24pt"), selection: { _ in self.selectFeedback() }),
            .init(name: "Rate the App", image: #imageLiteral(resourceName: "baseline_star_rate_black_24pt"), selection: { _ in self.selectReviewApp() }),
            .init(name: "Tell Friends", image: #imageLiteral(resourceName: "baseline_share_black_24pt"), selection: selectTellFriends)
        ]
        
        moreNavigationController.setViewControllers([moreController], animated: false)

        return moreNavigationController
    }
    
    private func selectFAQ() {
        let faqController = UIStoryboard(name: "More", bundle: .init(for: FAQViewController.self)).instantiateViewController(withIdentifier: "FAQViewController") as! FAQViewController
        faqController.tableModel = faq
        moreNavigationController.pushViewController(faqController, animated: true)
    }
    
    private func selectIAP() {
        let iapController = IAPUIComposer.iap()
        IAPTransactionObserver.shared.delegate = iapController
        moreNavigationController.pushViewController(iapController, animated: true)
    }
    
    private func selectFeedback() {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: NSLocalizedString("No Email Function Available", comment: "6th"), message: NSLocalizedString("We're sorry. Please leave a review in the AppStore instead.", comment: "6th"), preferredStyle: .alert)
            
            let ok = UIAlertAction(title: NSLocalizedString("Here we go!", comment: "6th"), style: .default) { _ in
                self.selectReviewApp()
            }
            
            let cancel = UIAlertAction(title: NSLocalizedString("Maybe later", comment: "6th"), style: .cancel)
            
            alert.addAction(ok)
            alert.addAction(cancel)
            
            moreNavigationController.showDetailViewController(alert, sender: self)
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
        moreNavigationController.present(composeVC, animated: true) {
        }
    }
  
    private func selectReviewApp() {
        guard let writeReviewURL = URL(string: Constants.appStoreReviewUrl)
            else { fatalError("Expected a valid URL") }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
   
    func selectTellFriends(anchorView: UIView?){
        var activityItems: [Any] = [NSLocalizedString("Come play \"1A2B Fun!\". Enjoy the simple logic game without taking too much time!", comment: "9th")]
        activityItems.append(Constants.appStoreDownloadUrl)

        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.popoverPresentationController?.sourceView = anchorView ?? moreNavigationController.view
            controller.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 22, width: 56, height: 0)
        moreNavigationController.showDetailViewController(controller, sender: self)
    }
}

extension AppDelegate: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}


private let faq = [Question(
                    content: NSLocalizedString("QUESTION_AD_NOT_SHOWING",
                                               tableName: "Localizable",
                                               bundle: .main,
                                               comment: "A question about why an ad is not always showing when the player is out of chances"),
                    answer:  NSLocalizedString("ANSWER_AD_NOT_SHOWING",
                                               tableName: "Localizable",
                                               bundle: .main,
                                               comment: "An answer to why an ad is not always showing when the player is out of chances"))]
