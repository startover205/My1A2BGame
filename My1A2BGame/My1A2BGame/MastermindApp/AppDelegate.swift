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
    
    private lazy var tabController = BannerAdTabBarViewController()
    private lazy var basicGameNavigationController = UINavigationController()
    private lazy var advancedGameNavigationController = UINavigationController()

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
        
        SKPaymentQueue.default().add(StoreObserver.shared)
        
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
        SKPaymentQueue.default().remove(StoreObserver.shared)
    }
    
    func configureWindow() {
        window?.rootViewController = makeTabController()
        
        window?.makeKeyAndVisible()
        
        startNewBasicGame()
        
        startNewAdvancedGame()
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
        let moreNav = UINavigationController(rootViewController: makeMoreVC())
        
        tabController.setViewControllers([basicGameNavigationController, advancedGameNavigationController, rankNav, moreNav], animated: false)
        
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
        let vc = UIStoryboard(name: "More", bundle: .init(for: MoreViewController.self)).instantiateViewController(withIdentifier: "MoreViewController")
        vc.title = "More"
        return vc
    }
}
