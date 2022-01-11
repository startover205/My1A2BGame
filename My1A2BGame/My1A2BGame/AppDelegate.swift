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
    
    private lazy var tabController = UITabBarController()
    private lazy var basicGameNavigationController = UINavigationController()
    private lazy var advancedGameNavigationController = UINavigationController()
    private lazy var moreNavigationController = UINavigationController()
    private weak var bannerAd: UIView?
    private var hasPurchasedRemovingAd: Bool { userDefaults.bool(forKey: UserDefaults.Key.remove_bottom_ad) }

    private let basicGameVersion: GameVersion = .basic
    private let advancedGameVersion: GameVersion = .advanced
    
    private lazy var secretGenerator: (Int) -> DigitSecret = RandomDigitSecretGenerator.generate(digitCount:)
    
    private lazy var rewardAdLoader: RewardAdLoader = GoogleRewardAdLoader(adUnitID: Constants.rewardAdId)
    
    private lazy var requestReview: () -> Void = {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            SKStoreReviewController.requestReview()
        }
    }
    
    private lazy var userDefaults: UserDefaults = .standard
    
    private lazy var allProductIDs: [String] = [IAPProduct.removeBottomAd]
    private lazy var transactionObserver: IAPTransactionObserver = IAPTransactionObserver.shared
    private lazy var paymentQueue: SKPaymentQueue = .default()
    private lazy var productLoader: IAPProductLoader = IAPProductLoader(makeRequest: SKProductsRequest.init, getProductIDs: { [allProductIDs, purhcaseRecordStore] in
        Set(allProductIDs.filter { !purhcaseRecordStore.hasPurchaseProduct(productIdentifier: $0) })
    })
    private lazy var purhcaseRecordStore: UserDefaultsPurchaseRecordStore = .init(userDefaults: userDefaults)
    
    private lazy var appReviewController: AppReviewController? = {
        guard let appVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String else { return nil }
        return CounterAppReviewController(
            userDefaults: userDefaults,
            askForReview: requestReview,
            targetProcessCompletedCount: 3,
            appVersion: appVersion)
    }()
    
    private weak var iapController: IAPViewController?
    
    convenience init(userDefaults: UserDefaults, secretGenerator: @escaping (Int) -> DigitSecret, rewardAdLoader: RewardAdLoader, requestReview: @escaping () -> Void, basicRecordLoader: RecordLoader, advancedRecordLoader: RecordLoader) {
        self.init()
        
        self.userDefaults = userDefaults
        self.secretGenerator = secretGenerator
        self.rewardAdLoader = rewardAdLoader
        self.requestReview = requestReview
        self.basicRecordLoader = basicRecordLoader
        self.advancedRecordLoader = advancedRecordLoader
    }
    
    convenience init(userDefaults: UserDefaults, transactionObserver: IAPTransactionObserver, paymentQueue: SKPaymentQueue, productLoader: IAPProductLoader?) {
        self.init()
        
        self.userDefaults = userDefaults
        self.transactionObserver = transactionObserver
        self.paymentQueue = paymentQueue
        if let loader = productLoader {
            self.productLoader = loader
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 設定廣告
        if #available(iOS 14, *) {
            // requestIDFA
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                
                // setup ad
                GADMobileAds.sharedInstance().start(completionHandler: nil)
            })
        } else {
            GADMobileAds.sharedInstance().start(completionHandler: nil)
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        configureWindow()
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        paymentQueue.remove(transactionObserver)
    }
    
    func configureWindow() {
        window?.rootViewController = makeTabController()
        
        window?.makeKeyAndVisible()
        
        startNewBasicGame()
        
        startNewAdvancedGame()
        
        configureIAPTransactionObserver()
        
        configureBannerAd()
    }
    
    func configureBannerAd() {
        if !hasPurchasedRemovingAd {
            let tabBar = tabController.tabBar
            let bannerWidth = tabBar.frame.inset(by: tabBar.safeAreaInsets).size.width
            
            let bannerAd = GADBannerView()
            bannerAd.adSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(bannerWidth)
            bannerAd.rootViewController = tabController
            bannerAd.adUnitID = Constants.bottomAdId
            bannerAd.load(GADRequest())
            
            tabBar.addSubview(bannerAd)
            bannerAd.translatesAutoresizingMaskIntoConstraints = false
            tabBar.topAnchor.constraint(equalTo: bannerAd.bottomAnchor).isActive = true
            tabBar.leftAnchor.constraint(equalTo: bannerAd.leftAnchor).isActive = true
            tabBar.rightAnchor.constraint(equalTo: bannerAd.rightAnchor).isActive = true
            
            let newInset = UIEdgeInsets(top: 0, left: 0, bottom: bannerAd.bounds.height, right: 0)
            for child in tabController.children {
                child.additionalSafeAreaInsets = newInset
            }
            self.bannerAd = bannerAd
        }
    }
    
    private func configureIAPTransactionObserver() {
        transactionObserver.onTransactionError = { error in
            let alert = UIAlertController(title: NSLocalizedString("PURCHASE_ERROR", comment: "The message for purchase error"), message: error?.localizedDescription, preferredStyle: .alert)
            
            let ok = UIAlertAction(title: NSLocalizedString("MESSAGE_DISMISS_ACTION", comment: "The button to dismiss alert message"), style: .default)
            
            alert.addAction(ok)
            
            self.tabController.showDetailViewController(alert, sender: self)
        }
        
        let buyingProductHandler = { (productIdentifier: String) in
            guard self.allProductIDs.contains(productIdentifier) else {
                let format = NSLocalizedString("UNKNOWN_PRODUCT_MESSAGE_FOR_%@", comment: "The format for message shown when the app receives an unknown product identifier")
                let alert = UIAlertController(title: String.localizedStringWithFormat(format, productIdentifier),message: nil, preferredStyle: .alert)
                
                let ok = UIAlertAction(title: NSLocalizedString("MESSAGE_DISMISS_ACTION", comment: "The dismiss button title"), style: .default)
                
                alert.addAction(ok)
                
                self.tabController.showDetailViewController(alert, sender: self)
                
                return
            }
            
            self.purhcaseRecordStore.insertPurchaseRecord(productIdentifier: productIdentifier)
            
            if productIdentifier == IAPProduct.removeBottomAd {
                self.bannerAd?.alpha = 0
                self.tabController.children.forEach {
                    $0.additionalSafeAreaInsets = .zero
                }
            }
            
            self.iapController?.refresh()
        }
        
        transactionObserver.onPurchaseProduct = buyingProductHandler
        
        transactionObserver.onRestoreProduct = buyingProductHandler
        
        transactionObserver.onRestorationFinishedWithError = { error in
            let alert = UIAlertController(title: NSLocalizedString("RESTORE_PURCHASE_ERROR", comment: "The message for restoration failure"), message: error.localizedDescription, preferredStyle: .alert)
            
            let ok = UIAlertAction(title: NSLocalizedString("MESSAGE_DISMISS_ACTION", comment: "The dismiss button title"), style: .default)
            
            alert.addAction(ok)
            
            self.tabController.showDetailViewController(alert, sender: self)
        }
        
        transactionObserver.onRestorationFinished = { hasRestorableContent in
            let title = hasRestorableContent ? NSLocalizedString("RESTORE_PURCHASE_SUCCESS", comment: "The message shown for successful restoration") : NSLocalizedString("NO_RESTORABLE_PRODUCT_MESSAGE", comment: "The message shown when there's no restorable products")
        
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            
            let ok = UIAlertAction(title: NSLocalizedString("MESSAGE_DISMISS_ACTION", comment: "The button to dismiss alert message"), style: .default)

            alert.addAction(ok)

            self.tabController.showDetailViewController(alert, sender: self)
        }
        
        paymentQueue.add(transactionObserver)
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
        let rewardAdViewController = RewardAdControllerComposer.rewardAdComposedWith(
            loader: rewardAdLoader,
            rewardChanceCount: Constants.adGrantChances,
            hostViewController: tabController)
        let controller = GameUIComposer.gameComposedWith(
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
        let iapController = IAPUIComposer.iapComposedWith(productLoader: productLoader, paymentQueue: paymentQueue)
        self.iapController = iapController
        moreNavigationController.pushViewController(iapController, animated: true)
    }
    
    private func selectFeedback() {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: NSLocalizedString("EMAIL_UNAVAILABLE_MESSAGE", comment: "The message shown when the user's device doesn't have email functionality"), message: NSLocalizedString("APP_REVIEW_SUGGESTION_MESSAGE", comment: "The message suggestting the user to leave a review in the app store when email is not available"), preferredStyle: .alert)
            
            let ok = UIAlertAction(title: NSLocalizedString("APP_REVIEW_ACTION", comment: "The button to open the app review page"), style: .default) { _ in
                self.selectReviewApp()
            }
            
            let cancel = UIAlertAction(title: NSLocalizedString("APP_REVIEW_CANCEL_ACTION", comment: "The button to cancel review"), style: .cancel)
            
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
        var activityItems: [Any] = [NSLocalizedString("APP_PROMOTIONAL_MESSAGE", comment: "The message to promote the app with friends")]
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
