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
import GameKit


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
        
        //        #if DEBUG
        //        fakeRecord()
        //        #endif
        
        window = UIWindow()
        configureWindow()
        
        return true
    }
    
//    func fakeRecord(){
//        let names = ["Emma", "Sam", "Judy", "John", "Joe", "Joey", "Emily", "Tim"]
//        let guessTimes = [4, 5, 8, 9, 12, 4, 6, 8]
//        let spentTimes = [124, 173, 100, 245, 192, 52, 493, 291]
//
//        for i in 0..<names.count {
//            let user: Winner = winnerCoreDataManager.createObject()
//            user.name = names[i]
//            user.guessTimes = Int16(guessTimes[i])
//            user.spentTime = Double(spentTimes[i])
//            user.date = Date()
//        }
//
//        winnerCoreDataManager.saveContext(completion: nil)
//    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(StoreObserver.shared)
    }
    
    func configureWindow() {
        window?.rootViewController = makeTabController()
        
        window?.makeKeyAndVisible()
    }
    
    private lazy var basicGameNavigationController = UINavigationController(
        rootViewController: GameUIComposer.gameComposedWith(
            gameVersion: BasicGame(),
            userDefaults: .standard,
            adProvider: GoogleRewardAdManager.shared,
            onWin: showWinSceneForBasicGame))
    
    private lazy var advancedGameNavigationController = UINavigationController(
        rootViewController: GameUIComposer.gameComposedWith(
            gameVersion: AdvancedGame(),
            userDefaults: .standard,
            adProvider: GoogleRewardAdManager.shared,
            onWin: showWinSceneForAdvancedGame))

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
        let winScene = WinUIComposer.winComposedWith(gameVersion: BasicGame(), userDefaults: .standard, recordLoader: recordLoader)
        basicGameNavigationController.pushViewController(winScene, animated: true)
    }
    
    private func showWinSceneForAdvancedGame(guessCount: Int, guessTime: TimeInterval) {
        let store = try! CoreDataRecordStore<AdvancedWinner>(storeURL: advancedGameStoreURL, modelName: "ModelAdvanced")
        let recordLoader = LocalRecordLoader(store: store)
        let winScene = WinUIComposer.winComposedWith(gameVersion: AdvancedGame(), userDefaults: .standard, recordLoader: recordLoader)
        basicGameNavigationController.pushViewController(winScene, animated: true)
    }
}

public final class WinUIComposer {
    private init() {}
    
    public static func winComposedWith(gameVersion: GameVersion, userDefaults: UserDefaults, recordLoader: RecordLoader) -> WinViewController {
        
        let winViewController = makeWinViewController()
        let recordViewController = winViewController.recordViewController!
        recordViewController.hostViewController = winViewController
        recordViewController.loader = recordLoader
        recordViewController.guessCount = { [unowned winViewController] in winViewController.guessCount }
        recordViewController.spentTime = { [unowned winViewController] in winViewController.spentTime }
        recordViewController.currentDate = Date.init
        
        winViewController.digitCount = gameVersion.digitCount
        winViewController.userDefaults = userDefaults
        winViewController.askForReview = { completion in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                SKStoreReviewController.requestReview()
                completion()
            }
        }
        winViewController.showFireworkAnimation = showFireworkAnimation(on:)
        
        let shareViewController = ShareViewController(
            hostViewController: winViewController,
            guessCount: { [unowned winViewController] in winViewController.guessCount })
        winViewController.shareViewController = shareViewController
        
        return winViewController
    }
    
    private static func makeWinViewController() -> WinViewController {
        let winController = UIStoryboard(name: "Game", bundle: .init(for: WinViewController.self)).instantiateViewController(withIdentifier: "WinViewController") as! WinViewController
        
        return winController
    }
    
    private static func showFireworkAnimation(on view: UIView) {
        func showFirework(on view: UIView){
            var cellsForFirework = [CAEmitterCell]()
            
            let cellRect = CAEmitterCell()
            let cellHeart = CAEmitterCell()
            let cellStar = CAEmitterCell()
            
            cellsForFirework.append(cellRect)
            cellsForFirework.append(cellStar)
            cellsForFirework.append(cellHeart)
            
            for cell in cellsForFirework {
                cell.birthRate = 4500
                cell.lifetime = 2
                cell.velocity = 100
                cell.scale = 0
                cell.scaleSpeed = 0.2
                cell.yAcceleration = 30
                cell.color = #colorLiteral(red: 1, green: 0.8302680122, blue: 0.3005099826, alpha: 1)
                cell.greenRange = 20
                cell.spin = CGFloat.pi
                cell.spinRange = CGFloat.pi * 3/4
                cell.emissionRange = CGFloat.pi
                cell.alphaSpeed = -1 / cell.lifetime
                
                cell.beginTime = CACurrentMediaTime()
                cell.timeOffset = 1
            }
            
            cellStar.contents = #imageLiteral(resourceName: "flake_star").cgImage
            cellHeart.contents = #imageLiteral(resourceName: "flake_heart").cgImage
            cellRect.contents = #imageLiteral(resourceName: "flake_rectangle").cgImage
            
            let emitterLayer = CAEmitterLayer()
            
            let randomDistribution = GKRandomDistribution(lowestValue: 1, highestValue: 8)
            
            var randomX = Double(randomDistribution.nextInt()) / 9
            var randomY = Double(randomDistribution.nextInt()) / 9
            
            while randomX <= 7/9 , randomX >= 2/9, randomY <= 7/9, randomY >= 2/9 {
                randomX = Double(randomDistribution.nextInt()) / 9
                randomY = Double(randomDistribution.nextInt()) / 9
            }
            
            emitterLayer.emitterPosition = CGPoint(x: view.frame.width * CGFloat(randomX) , y: view.frame.height * CGFloat(randomY))
            
            emitterLayer.emitterCells = cellsForFirework
            emitterLayer.renderMode = CAEmitterLayerRenderMode.oldestLast
            view.layer.insertSublayer(emitterLayer, at: 0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak emitterLayer] in
                emitterLayer?.removeFromSuperlayer()
            }
        }
        
        for i in 0...20 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) { [weak view] in
                guard let view = view else { return }
                showFirework(on: view)
            }
        }
    }
}
