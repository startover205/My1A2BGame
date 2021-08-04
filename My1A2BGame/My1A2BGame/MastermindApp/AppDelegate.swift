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
        
        //        #if DEBUG
        //        fakeRecord()
        //        #endif
        
        window = UIWindow()
        configureWindow()
        
        return true
    }
    
    func fakeRecord(){
        let names = ["Emma", "Sam", "Judy", "John", "Joe", "Joey", "Emily", "Tim"]
        let guessTimes = [4, 5, 8, 9, 12, 4, 6, 8]
        let spentTimes = [124, 173, 100, 245, 192, 52, 493, 291]
        
        for i in 0..<names.count {
            let user = winnerCoreDataManager.createObject()
            user.name = names[i]
            user.guessTimes = Int16(guessTimes[i])
            user.spentTime = Double(spentTimes[i])
            user.date = Date()
        }
        
        winnerCoreDataManager.saveContext(completion: nil)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(StoreObserver.shared)
    }
    
    func configureWindow() {
        window?.rootViewController = makeTabController()
        
        window?.makeKeyAndVisible()
    }
    
    func makeTabController() -> UITabBarController {
        let tabVC = UITabBarController()
        let basicGameNav = UINavigationController(rootViewController: makeBasicVC())
        let advancedGameNav = UINavigationController(rootViewController: makeAdvancedVC())
        let rankNav = UINavigationController(rootViewController: makeRankVC())
        let moreNav = UINavigationController(rootViewController: makeMoreVC())
        
        tabVC.setViewControllers([basicGameNav, advancedGameNav, rankNav, moreNav], animated: false)
        tabVC.tabBar.items![0].image = UIImage(named: "baseline_1A2B_24px")
        tabVC.tabBar.items![1].image = UIImage(named: "advanced_24px")
        tabVC.tabBar.items![2].image = UIImage(named: "baseline_format_list_numbered_black_24pt")
        tabVC.tabBar.items![3].image = UIImage(named: "baseline_settings_black_24pt")
        return tabVC
    }
    
    private func makeBasicVC() -> UIViewController {
        let controller = GameUIComposer.makeGameUI(gameVersion: BasicGame(), userDefaults: .standard)
        controller.adProvider = GoogleRewardAdManager.shared

        return controller
    }
    
    private func makeAdvancedVC() -> UIViewController {
        let controller = GameUIComposer.makeGameUI(gameVersion: AdvancedGame(), userDefaults: .standard)
        controller.adProvider = GoogleRewardAdManager.shared

        return controller
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
}

