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
    
    public static func gameComposedWith(title: String, gameVersion: GameVersion, userDefaults: UserDefaults, loader: RewardAdLoader, secret: DigitSecret, onRestart: @escaping () -> Void, animate: @escaping Animate) -> GuessNumberViewController {
        let voicePromptViewController = VoicePromptViewController(userDefaults: userDefaults)
        
        let inputVC = makeInputPadUI()
        inputVC.digitCount = gameVersion.digitCount

        let gameViewController = makeGameViewController()
        gameViewController.title = title
        gameViewController.availableGuess = gameVersion.maxGuessCount
        
        gameViewController.voicePromptViewController = voicePromptViewController
        voicePromptViewController.onToggleSwitch = { [unowned gameViewController] isOn in
            if isOn {
                let alertController = UIAlertController(title: NSLocalizedString("Voice-Prompts Feature is On", comment: ""), message: NSLocalizedString("Siri will speak out the result for you.", comment: "2nd"), preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
                
                alertController.addAction(okAction)
                gameViewController.present(alertController, animated: true, completion: nil)
            }
        }
        
        gameViewController.inputVC = inputVC
        inputVC.delegate = gameViewController
        
        gameViewController.onRestart = onRestart
        gameViewController.animate = animate
        
        gameViewController.helperViewController?.animate = animate
        gameViewController.helperViewController?.onTapHelperInfo = {
            AlertManager.shared.showConfirmAlert(.helperInfo)
        }
        
        gameViewController.quizLabelViewController.answer = secret.content
        
        gameViewController.hintViewController.animate = animate
        
        let adRewardChance = Constants.adGrantChances
        let adViewController = RewardAdViewController(
            loader: loader,
            adRewardChance: adRewardChance,
            countDownTime: 5,
            onGrantReward: { [unowned gameViewController] in
                gameViewController.availableGuess += adRewardChance
            },
            hostViewController: gameViewController)
        gameViewController.adViewController = adViewController
        
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
