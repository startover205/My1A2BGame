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
        let tabVC = UITabBarController()
        let basicGameNav = UINavigationController(rootViewController: makeBasicVC())
        let advancedGameNav = UINavigationController(rootViewController: makeAdvancedVC())
        let rankNav = UINavigationController(rootViewController: makeRankVC())
        let moreNav = UINavigationController(rootViewController: makeMoreVC())
        
        tabVC.setViewControllers([basicGameNav, advancedGameNav, rankNav, moreNav], animated: false)
        window?.rootViewController = tabVC
        
        window?.makeKeyAndVisible()
    }
    
    private func makeBasicVC() -> UIViewController {
        let vc = UIStoryboard(name: "Main", bundle: .init(for: GuessNumberViewController.self)).instantiateViewController(withIdentifier: "GuessViewController")
        vc.title = "Basic"
        return vc
    }
    
    private func makeAdvancedVC() -> UIViewController {
        let vc = UIStoryboard(name: "Main", bundle: .init(for: GuessNumberViewController.self)).instantiateViewController(withIdentifier: "GuessAdvancedViewController")
        vc.title = "Advanced"
        return vc
    }
    
    private func makeRankVC() -> UIViewController {
        let vc = UIStoryboard(name: "Main", bundle: .init(for: RankViewController.self)).instantiateViewController(withIdentifier: "RankViewController")
        vc.title = "Rank"
        return vc
    }
    
    private func makeMoreVC() -> UIViewController {
        let vc = UIStoryboard(name: "Main", bundle: .init(for: SettingsTableViewController.self)).instantiateViewController(withIdentifier: "SettingsTableViewController")
        vc.title = "More"
        return vc
    }
}

