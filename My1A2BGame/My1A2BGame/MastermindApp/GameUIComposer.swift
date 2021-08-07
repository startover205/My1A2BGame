//
//  GameUIComposer.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/7/25.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit
import Mastermind
import MastermindiOS
import StoreKit
import GameKit

public final class GameUIComposer {
    public static func gameComposedWith(gameVersion: GameVersion, userDefaults: UserDefaults) -> GuessNumberViewController {
        let voicePromptViewController = VoicePromptViewController(userDefaults: userDefaults)
        let inputVC = makeInputPadUI(digitCount: gameVersion.digitCount)
        let gameViewController = makeGameViewController(gameVersion: gameVersion)
        
        gameViewController.winViewController = makeWinViewController(isAdvancedVersion: gameVersion.digitCount == 5, advancedWinnerStore: advancedWinnerCoreDataManager, winnerStore: winnerCoreDataManager, userDefaults: userDefaults)
        
        gameViewController.voicePromptViewController = voicePromptViewController
        voicePromptViewController.onToggleSwitch = { [weak gameViewController] isOn in
            if isOn { gameViewController?.showVoicePromptHint() }
        }
        
        inputVC.delegate = gameViewController
        gameViewController.inputVC = inputVC
        
        gameViewController.evaluate = MastermindEvaluator.evaluate(_:with:)
        
        return gameViewController
    }
    
    private static func makeGameViewController(gameVersion: GameVersion) -> GuessNumberViewController {
        let gameController = UIStoryboard(name: "Game", bundle: .init(for: GuessNumberViewController.self)).instantiateViewController(withIdentifier: "GuessViewController") as! GuessNumberViewController
        gameController.title = gameVersion.title
        gameController.gameVersion = gameVersion
        return gameController
    }
    
    public static func makeInputPadUI(digitCount: Int) -> GuessPadViewController {
        let controller = UIStoryboard(name: "Game", bundle: .init(for: GuessPadViewController.self)).instantiateViewController(withIdentifier: "GuessPadViewController") as! GuessPadViewController
        controller.digitCount = digitCount
        
        return controller
    }
    
    public static func makeWinViewController(isAdvancedVersion: Bool, advancedWinnerStore: AdvancedWinnerStore, winnerStore: WinnerStore, userDefaults: UserDefaults) -> WinViewController {
        let winController = UIStoryboard(name: "Game", bundle: .init(for: WinViewController.self)).instantiateViewController(withIdentifier: "WinViewController") as! WinViewController
        winController.isAdvancedVersion = isAdvancedVersion
        winController.advancedWinnerStore =  advancedWinnerStore
        winController.winnerStore = winnerStore
        winController.userDefaults = userDefaults
        winController.askForReview = { completion in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                SKStoreReviewController.requestReview()
                completion()
            }
        }
        winController.showFireworkAnimation = { view in
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
        return winController
    }
}
//