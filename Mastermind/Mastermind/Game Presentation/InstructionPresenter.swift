//
//  InstructionPresenter.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/9/28.
//

import Foundation

public final class GameInstructionPresenter {
    private init() {}
    
    public static var instruction: String {
        NSLocalizedString("INSTRUCTION",
                          tableName: "Game",
                          bundle: Bundle(for: GameInstructionPresenter.self),
                          comment: "Instruction for the game")
    }
}
