//
//  AppDelegate.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2018/5/30.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import UIKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var reachability = Reachability.forInternetConnection()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        SKPaymentQueue.default().add(StoreObserver.shared)
        
        setUpAd()
        
        tryToLoadRewardAd()
        
        NotificationCenter.default.addObserver(self, selector: #selector(tryToLoadRewardAd), name: NSNotification.Name.reachabilityChanged, object: nil)
        
        reachability?.startNotifier()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(StoreObserver.shared)
    }
}

// MARK: - GADRewardBasedVideoAdDelegate
extension AppDelegate: GADRewardBasedVideoAdDelegate {
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        NotificationCenter.default.post(name: .adDidReward, object: nil)
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        tryToLoadRewardAd()
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
        tryToLoadRewardAd()
    }
}

// MARK: - Static function
extension AppDelegate {
    static func internetAvailable() -> Bool {
        let serverReach = Reachability.forInternetConnection()
        return serverReach?.currentReachabilityStatus() != NotReachable
    }
}

// MARK: - Private
private extension AppDelegate {
    func setUpAd(){
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        GADRewardBasedVideoAd.sharedInstance().delegate = self
    }
    
    @objc
    func tryToLoadRewardAd(){
        
        if AppDelegate.internetAvailable() {
            GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
                                                        withAdUnitID: Constants.rewardAdId)
        }
    }
}
