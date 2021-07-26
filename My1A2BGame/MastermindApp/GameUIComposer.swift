//
//  GameUIComposer.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/7/25.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit

public final class GameUIComposer {
    public static func makeGameUI(gameVersion: GameVersion) -> GuessNumberViewController {
        let controller = UIStoryboard(name: "Game", bundle: .init(for: GuessNumberViewController.self)).instantiateViewController(withIdentifier: "GuessViewController") as! GuessNumberViewController
        controller.gameVersion = gameVersion
        controller.title = gameVersion.title
        
        return controller
    }
}
