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
    public static func makeGameUI(gameVersion: GameVersion) -> GuessNumberViewController {
        let controller = UIStoryboard(name: "Game", bundle: .init(for: GuessNumberViewController.self)).instantiateViewController(withIdentifier: "GuessViewController") as! GuessNumberViewController
        controller.gameVersion = gameVersion
        controller.title = gameVersion.title
        let inputVC = makeInputPadUI(digitCount: gameVersion.digitCount)
        inputVC.delegate = controller
        controller.inputVC = inputVC
        controller.evaluate = MastermindEvaluator.evaluate(_:with:)

        
        return controller
    }
    
    public static func makeInputPadUI(digitCount: Int) -> GuessPadViewController {
        let controller = UIStoryboard(name: "Game", bundle: .init(for: GuessPadViewController.self)).instantiateViewController(withIdentifier: "GuessPadViewController") as! GuessPadViewController
        controller.digitCount = digitCount
        
        return controller
    }
}
