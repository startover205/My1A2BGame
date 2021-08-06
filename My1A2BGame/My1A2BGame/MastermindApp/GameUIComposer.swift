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

public final class GameUIComposer {
    public static func gameComposedWith(gameVersion: GameVersion, userDefaults: UserDefaults) -> GuessNumberViewController {
        let voicePromptViewController = VoicePromptViewController(userDefaults: userDefaults)
        let inputVC = makeInputPadUI(digitCount: gameVersion.digitCount)

        let gameViewController = UIStoryboard(name: "Game", bundle: .init(for: GuessNumberViewController.self)).instantiateViewController(withIdentifier: "GuessViewController") as! GuessNumberViewController
        gameViewController.title = gameVersion.title
        gameViewController.gameVersion = gameVersion
        
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
        
        return winController
    }
}
