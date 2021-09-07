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
    
    private lazy var basicGameNavigationController = UINavigationController()
    private lazy var advancedGameNavigationController = UINavigationController()

    private var basicChallenge: Challenge?
    private var advancedChallenge: Challenge?
    
    private let basicGameVersion: GameVersion = .basic
    private let advancedGameVersion: GameVersion = .advanced
    
    private lazy var secretGenerator: (Int) -> DigitSecret = RandomDigitSecretGenerator.generate(digitCount:)
    
    private lazy var rewardAdLoader: RewardAdLoader = GoogleRewardAdManager.shared
    
    convenience init(secretGenerator: @escaping (Int) -> DigitSecret, rewardAdLoader: RewardAdLoader) {
        self.init()
        self.secretGenerator = secretGenerator
        self.rewardAdLoader = rewardAdLoader
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
    
    private func makeTabController() -> UITabBarController {
        let tabConfigurations: [(title: String, imageName: String)] = [
            (basicGameVersion.title, "baseline_1A2B_24px"),
            (advancedGameVersion.title, "advanced_24px"),
            ("Rank", "baseline_format_list_numbered_black_24pt"),
            ("More", "baseline_settings_black_24pt"),
        ]
        let tabVC = BannerAdTabBarViewController()
        let rankNav = UINavigationController(rootViewController: makeRankVC())
        let moreNav = UINavigationController(rootViewController: makeMoreVC())

        tabVC.setViewControllers([basicGameNavigationController, advancedGameNavigationController, rankNav, moreNav], animated: false)
        
        tabVC.tabBar.items!.enumerated().forEach { index, item in
            item.title = tabConfigurations[index].title
            item.image = UIImage(named: tabConfigurations[index].imageName)
        }
        
        return tabVC
    }
}

private extension AppDelegate {
    private func startNewBasicGame() {
        let gameVersion = basicGameVersion
        let secret = secretGenerator(gameVersion.digitCount)
        let delegate = makeGameDelegate(
            navigationController: basicGameNavigationController,
            secret: secret,
            gameVersion: gameVersion,
            onRestart: startNewBasicGame,
            recordLoader: basicRecordLoader)
        
        basicChallenge = Challenge.start(
            secret: secret,
            maxChanceCount: gameVersion.maxGuessCount,
            matchGuess: DigitSecretMatcher.match(_:with:),
            delegate: delegate)
    }
    
    private func startNewAdvancedGame() {
        let gameVersion = advancedGameVersion
        let secret = secretGenerator(gameVersion.digitCount)
        let delegate = makeGameDelegate(
            navigationController: advancedGameNavigationController,
            secret: secret,
            gameVersion: gameVersion,
            onRestart: startNewAdvancedGame,
            recordLoader: advancedRecordLoader)
        
        advancedChallenge = Challenge.start(
            secret: secret,
            maxChanceCount: gameVersion.maxGuessCount,
            matchGuess: DigitSecretMatcher.match(_:with:),
            delegate: delegate)
    }
    
    private func makeGameDelegate(navigationController: UINavigationController, secret: DigitSecret, gameVersion: GameVersion, onRestart: @escaping () -> Void, recordLoader: RecordLoader) -> GameNavigationAdapter {
        let gameController = makeGameController(secret: secret, gameVersion: gameVersion, onRestart: onRestart)
        let rewardAdController = RewardAdViewController(
            loader: rewardAdLoader,
            adRewardChance: 5,
            countDownTime: 5.0,
            onGrantReward: {},
            hostViewController: gameController)
        let delegate = GameNavigationAdapter(
            navigationController: navigationController,
            gameComposer: adaptGameControllerToGameComposer(controller: gameController),
            winComposer: makeWinComposer(
                digitCount: gameVersion.digitCount,
                recordLoader: recordLoader),
            loseComposer: LoseUIComposer.loseScene,
            delegate: rewardAdController,
            currentDeviceTime: CACurrentMediaTime)
        return delegate
    }
    
    private func makeGameController(secret: DigitSecret, gameVersion: GameVersion, onRestart: @escaping () -> Void) -> GuessNumberViewController {
        let controller = GameUIComposer.gameComposedWith(
            gameVersion: gameVersion,
            userDefaults: .standard,
            loader: rewardAdLoader,
            secret: secret,
            onRestart: onRestart,
            animate: UIView.animate)
        
        controller.onGiveUp = { [weak controller] in
            let alert = UIAlertController(
                title: NSLocalizedString("Are you sure you want to give up?", comment: ""),
                message: nil,
                preferredStyle: .alert)
            
            let ok = UIAlertAction(
                title: NSLocalizedString("Give Up!", comment: "2nd"),
                style: .destructive) { [weak controller] _ in
                controller?.navigationController?.pushViewController(LoseUIComposer.loseScene(), animated: true)
                controller?.onGameLose()
            }
            
            let cancel = UIAlertAction(
                title: NSLocalizedString("Cancel", comment: "2nd"),
                style: .cancel)
            
            alert.addAction(ok)
            alert.addAction(cancel)
            
            controller?.present(alert, animated: true)
        }
        
        return controller
    }
    
    private func adaptGameControllerToGameComposer(controller: GuessNumberViewController) -> (@escaping GuessCompletion) -> UIViewController {
        return { guessCompletion in
            
            controller.guessCompletion = guessCompletion
            
            return controller
        }
    }
    
    private func makeWinComposer(digitCount: Int, recordLoader: RecordLoader) -> (Score) -> UIViewController {
        return { score in
            WinUIComposer.winComposedWith(
                score: score,
                digitCount: digitCount,
                recordLoader: recordLoader)
        }
    }
    
    private func storeURL(for modelName: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(modelName + ".sqlite")
    }
}

private extension AppDelegate {
    func makeRankVC() -> UIViewController {
        let vc = UIStoryboard(name: "Rank", bundle: .init(for: RankViewController.self)).instantiateViewController(withIdentifier: "RankViewController")
        vc.title = "Rank"
        return vc
    }
}

private extension AppDelegate {
     func makeMoreVC() -> UIViewController {
        let vc = UIStoryboard(name: "More", bundle: .init(for: SettingsTableViewController.self)).instantiateViewController(withIdentifier: "SettingsTableViewController")
        vc.title = "More"
        return vc
    }
}
