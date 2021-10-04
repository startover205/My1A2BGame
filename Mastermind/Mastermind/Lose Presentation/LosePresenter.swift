//
//  LosePresenter.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/10/4.
//

import Foundation

public final class LosePresenter {
    private init() {}
    
    private static var loseMessage: String {
        NSLocalizedString("LOSE_MESSAGE",
                          tableName: "Lose",
                          bundle: Bundle(for: LosePresenter.self),
                          comment: "Message for lose scene")
    }
    
    private static var encouragementMessage: String {
        NSLocalizedString("ENCOURAGEMENT_MESSAGE",
                          tableName: "Lose",
                          bundle: Bundle(for: LosePresenter.self),
                          comment: "Encouragement message for lose scene")
    }
    
    public static var loseViewModel: LoseViewModel {
        .init(loseMessage: Self.loseMessage, encouragementMessage: Self.encouragementMessage)
    }
}
