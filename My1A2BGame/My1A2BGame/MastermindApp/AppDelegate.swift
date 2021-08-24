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
    
    private lazy var basicGameNavigationController = UINavigationController(
        rootViewController: GameUIComposer.gameComposedWith(
            gameVersion: BasicGame(),
            userDefaults: .standard,
            adProvider: GoogleRewardAdManager.shared,
            onWin: { [self] in
                self.showWinSceneForBasicGame(guessCount: $0, guessTime: $1)
                self.appReviewController?.markProcessCompleteOneTime()
                self.appReviewController?.askForAppReviewIfAppropriate()
            }, onLose: showLoseSceneForBasicGame))
    
    private lazy var advancedGameNavigationController = UINavigationController(
        rootViewController: GameUIComposer.gameComposedWith(
            gameVersion: AdvancedGame(),
            userDefaults: .standard,
            adProvider: GoogleRewardAdManager.shared,
            onWin: { [self] in
                self.showWinSceneForAdvancedGame(guessCount: $0, guessTime: $1)
                self.appReviewController?.markProcessCompleteOneTime()
                self.appReviewController?.askForAppReviewIfAppropriate()
            }, onLose: showLoseSceneForAdvancedGame))
    
    func makeTabController() -> UITabBarController {
        let tabVC = UITabBarController()
        let rankNav = UINavigationController(rootViewController: makeRankVC())
        let moreNav = UINavigationController(rootViewController: makeMoreVC())
        
        tabVC.setViewControllers([basicGameNavigationController, advancedGameNavigationController, rankNav, moreNav], animated: false)
        tabVC.tabBar.items![0].image = UIImage(named: "baseline_1A2B_24px")
        tabVC.tabBar.items![1].image = UIImage(named: "advanced_24px")
        tabVC.tabBar.items![2].image = UIImage(named: "baseline_format_list_numbered_black_24pt")
        tabVC.tabBar.items![3].image = UIImage(named: "baseline_settings_black_24pt")
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
    
    private func showWinSceneForBasicGame(guessCount: Int, guessTime: TimeInterval) {
        let store = try! CoreDataRecordStore<Winner>(storeURL: basicGameStoreURL, modelName: "Model")
        let recordLoader = LocalRecordLoader(store: store)
        let winScene = WinUIComposer.winComposedWith(digitCount: BasicGame().digitCount, recordLoader: recordLoader)
        winScene.guessCount = guessCount
        winScene.guessTime = guessTime
        basicGameNavigationController.pushViewController(winScene, animated: true)
    }
    
    private func showLoseSceneForBasicGame() {
        let controller = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: String(describing: LoseViewController.self))
        basicGameNavigationController.pushViewController(controller, animated: true)
    }
    
    private func showLoseSceneForAdvancedGame() {
        let controller = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: String(describing: LoseViewController.self))
        advancedGameNavigationController.pushViewController(controller, animated: true)
    }
    
    private func showWinSceneForAdvancedGame(guessCount: Int, guessTime: TimeInterval) {
        let store = try! CoreDataRecordStore<AdvancedWinner>(storeURL: advancedGameStoreURL, modelName: "ModelAdvanced")
        let recordLoader = LocalRecordLoader(store: store)
        let winScene = WinUIComposer.winComposedWith(digitCount: AdvancedGame().digitCount, recordLoader: recordLoader)
        winScene.guessCount = guessCount
        winScene.guessTime = guessTime
        advancedGameNavigationController.pushViewController(winScene, animated: true)
    }
}
