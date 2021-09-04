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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var reachability = Reachability.forInternetConnection()
    
    private lazy var basicGameStoreURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Model" + ".sqlite")
    private lazy var advancedGameStoreURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ModelAdvanced" + ".sqlite")
    
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
    
    private lazy var appReviewController: AppReviewController? = {
        guard let appVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String else { return nil }
        return AppReviewController(
            userDefaults: .standard,
            askForReview: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    SKStoreReviewController.requestReview()
                }
            },
            targetProcessCompletedCount: 3,
            appVersion: appVersion)
    }()
    
    private lazy var basicGameNavigationController = UINavigationController()
    private lazy var advancedGameNavigationController = UINavigationController()

    private var basicChallenge: Challenge?
    private var advancedChallenge: Challenge?
    
    private let basicGameVersion = BasicGame()
    private let advancedGameVersion = AdvancedGame()
    
    private lazy var secretGenerator: (Int) -> DigitSecret = RandomDigitSecretGenerator.generate(digitCount:)
    
    convenience init(secretGenerator: @escaping (Int) -> DigitSecret) {
        self.init()
        self.secretGenerator = secretGenerator
    }
    
    private func startNewBasicGame() {
        let basicGameVersion = basicGameVersion
        let secret = secretGenerator(basicGameVersion.digitCount)
        
        let rewardAdController = RewardAdViewController(
            loader: GoogleRewardAdManager.shared,
            adRewardChance: 5,
            countDownTime: 5.0,
            onGrantReward: {})
        
        let delegate = GameNavigationAdapter(
            navigationController: basicGameNavigationController,
            gameComposer: { guessCompletion in
                return GameUIComposer.gameComposedWith(
                    gameVersion: basicGameVersion,
                    userDefaults: .standard,
                    loader: GoogleRewardAdManager.shared,
                    secret: secret,
                    guessCompletion: guessCompletion,
                    onWin: {_,_ in },
                    onLose: {},
                    onRestart: self.startNewBasicGame,
                    animate: UIView.animate)
            },
            winComposer: { score in
                WinUIComposer.winComposedWith(
                    score: score,
                    digitCount: basicGameVersion.digitCount,
                    recordLoader: self.basicRecordLoader)
            },
            loseComposer: LoseUIComposer.loseScene,
            delegate: rewardAdController,
            currentDeviceTime: CACurrentMediaTime)
        
        basicChallenge = Challenge.start(
            secret: secret,
            maxChanceCount: basicGameVersion.maxGuessCount,
            matchGuess: DigitSecretMatcher.match(_:with:),
            delegate: delegate)
    }

    private func startNewAdvancedGame() {
        let advancedGameVersion = advancedGameVersion
        let secret = secretGenerator(advancedGameVersion.digitCount)

        let rewardAdController = RewardAdViewController(
            loader: GoogleRewardAdManager.shared,
            adRewardChance: 5,
            countDownTime: 5.0,
            onGrantReward: {})
        
        let delegate = GameNavigationAdapter(
            navigationController: advancedGameNavigationController,
            gameComposer: { guessCompletion in

                return GameUIComposer.gameComposedWith(
                    gameVersion: advancedGameVersion,
                    userDefaults: .standard,
                    loader: GoogleRewardAdManager.shared,
                    secret: secret,
                    guessCompletion: guessCompletion,
                    onWin: {_,_ in },
                    onLose: {},
                    onRestart: self.startNewAdvancedGame,
                    animate: UIView.animate)
            },
            winComposer: { score in
                WinUIComposer.winComposedWith(
                    score: score,
                    digitCount: advancedGameVersion.digitCount,
                    recordLoader: self.advancedRecordLoader)
            },
            loseComposer: LoseUIComposer.loseScene,
            delegate: rewardAdController,
            currentDeviceTime: CACurrentMediaTime)
        
        advancedChallenge = Challenge.start(
            secret: secret,
            maxChanceCount: advancedGameVersion.maxGuessCount,
            matchGuess: DigitSecretMatcher.match(_:with:),
            delegate: delegate)
    }
    
    func makeTabController() -> UITabBarController {
        let tabConfigurations: [(title: String, imageName: String)] = [
            (BasicGame().title, "baseline_1A2B_24px"),
            (AdvancedGame().title, "advanced_24px"),
            ("Rank", "baseline_format_list_numbered_black_24pt"),
            ("More", "baseline_settings_black_24pt"),
        ]
        let tabVC = UITabBarController()
        let rankNav = UINavigationController(rootViewController: makeRankVC())
        let moreNav = UINavigationController(rootViewController: makeMoreVC())

        tabVC.setViewControllers([basicGameNavigationController, advancedGameNavigationController, rankNav, moreNav], animated: false)
        
        tabVC.tabBar.items!.enumerated().forEach { index, item in
            item.title = tabConfigurations[index].title
            item.image = UIImage(named: tabConfigurations[index].imageName)
        }
        
        return tabVC
    }
    
    private func makeRankVC() -> UIViewController {
        let vc = UIStoryboard(name: "Rank", bundle: .init(for: RankViewController.self)).instantiateViewController(withIdentifier: "RankViewController")
        vc.title = "Rank"
        return vc
    }
    
    private func makeMoreVC() -> UIViewController {
        let vc = UIStoryboard(name: "More", bundle: .init(for: SettingsTableViewController.self)).instantiateViewController(withIdentifier: "SettingsTableViewController")
        vc.title = "More"
        return vc
    }
    
    private lazy var basicRecordLoader: RecordLoader = {
        let store = try! CoreDataRecordStore<Winner>(storeURL: basicGameStoreURL, modelName: "Model")
        return LocalRecordLoader(store: store)
    }()
    
    private lazy var advancedRecordLoader: RecordLoader = {
        let store = try! CoreDataRecordStore<AdvancedWinner>(storeURL: advancedGameStoreURL, modelName: "ModelAdvanced")
        return LocalRecordLoader(store: store)
    }()
    
//    private func showWinSceneForBasicGame(guessCount: Int, guessTime: TimeInterval) {
//        let store = try! CoreDataRecordStore<Winner>(storeURL: basicGameStoreURL, modelName: "Model")
//        let recordLoader = LocalRecordLoader(store: store)
//        let winScene = WinUIComposer.winComposedWith(digitCount: BasicGame().digitCount, recordLoader: recordLoader)
//        winScene.guessCount = guessCount
//        winScene.guessTime = guessTime
//        basicGameNavigationController.pushViewController(winScene, animated: true)
//    }
//
//    private func showLoseSceneForBasicGame() {
//        let controller = LoseUIComposer.loseScene()
//        basicGameNavigationController.pushViewController(controller, animated: true)
//    }
//
//    private func showLoseSceneForAdvancedGame() {
//        let controller = LoseUIComposer.loseScene()
//        advancedGameNavigationController.pushViewController(controller, animated: true)
//    }
    
//    private func showWinSceneForAdvancedGame(guessCount: Int, guessTime: TimeInterval) {
//        let store = try! CoreDataRecordStore<AdvancedWinner>(storeURL: advancedGameStoreURL, modelName: "ModelAdvanced")
//        let recordLoader = LocalRecordLoader(store: store)
//        let winScene = WinUIComposer.winComposedWith(digitCount: AdvancedGame().digitCount, recordLoader: recordLoader)
//        winScene.guessCount = guessCount
//        winScene.guessTime = guessTime
//        advancedGameNavigationController.pushViewController(winScene, animated: true)
//    }
}
