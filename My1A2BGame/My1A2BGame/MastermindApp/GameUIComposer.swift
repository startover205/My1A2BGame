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
    
    public static func gameComposedWith(gameVersion: GameVersion, userDefaults: UserDefaults, adProvider: AdProvider, onWin: @escaping (_ guessCount: Int, _ guessTime: TimeInterval) -> Void, onLose: @escaping () -> Void, onRestart: @escaping () -> Void, animate: @escaping Animate) -> GuessNumberViewController {
        let voicePromptViewController = VoicePromptViewController(userDefaults: userDefaults)
        
        let inputVC = makeInputPadUI()
        inputVC.digitCount = gameVersion.digitCount

        let gameViewController = makeGameViewController()
        gameViewController.title = gameVersion.title
        gameViewController.gameVersion = gameVersion
        gameViewController.evaluate = MastermindEvaluator.evaluate(_:with:)
        
        let secret = RandomDigitSecretGenerator.generate(digitCount: gameVersion.digitCount)
        gameViewController.quizNumbers = secret.content.map(String.init)
        
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
        
        gameViewController.adProvider = adProvider
        gameViewController.onWin = onWin
        gameViewController.onLose = onLose
        gameViewController.onRestart = onRestart
        gameViewController.animate = animate
        
        gameViewController.helperViewController?.animate = animate
        gameViewController.helperViewController?.onTapHelperInfo = {
            AlertManager.shared.showConfirmAlert(.helperInfo)
        }
        
        gameViewController.quizLabelViewController.answer = secret.content
        
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
