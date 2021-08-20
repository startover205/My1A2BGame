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
    private init() {}
    
    public static func gameComposedWith(gameVersion: GameVersion, userDefaults: UserDefaults, adProvider: AdProvider, onWin: @escaping (_ guessCount: Int, _ guessTime: TimeInterval) -> Void) -> GuessNumberViewController {
        let voicePromptViewController = VoicePromptViewController(userDefaults: userDefaults)
        
        let inputVC = makeInputPadUI()
        inputVC.digitCount = gameVersion.digitCount

        let gameViewController = makeGameViewController()
        gameViewController.title = gameVersion.title
        gameViewController.gameVersion = gameVersion
        gameViewController.evaluate = MastermindEvaluator.evaluate(_:with:)
        
        gameViewController.voicePromptViewController = voicePromptViewController
        voicePromptViewController.onToggleSwitch = { [unowned gameViewController] isOn in
            if isOn { gameViewController.showVoicePromptHint() }
        }
        
        gameViewController.inputVC = inputVC
        inputVC.delegate = gameViewController
        
        gameViewController.adProvider = adProvider
        gameViewController.onWin = onWin
        
        return gameViewController
    }
    
    private static func makeGameViewController() -> GuessNumberViewController {
        let gameViewController = UIStoryboard(name: "Game", bundle: .init(for: GuessNumberViewController.self)).instantiateViewController(withIdentifier: "GuessViewController") as! GuessNumberViewController

        return gameViewController
    }
    
    public static func makeInputPadUI() -> GuessPadViewController {
        let controller = UIStoryboard(name: "Game", bundle: .init(for: GuessPadViewController.self)).instantiateViewController(withIdentifier: "GuessPadViewController") as! GuessPadViewController
        
        return controller
    }
}
//
