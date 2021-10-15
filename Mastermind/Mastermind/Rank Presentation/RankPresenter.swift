//
//  RankPresenter.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/10/7.
//

import Foundation

public final class RankPresenter {
    private let rankView: RankView
    
    public init(rankView: RankView) {
        self.rankView = rankView
    }
    
    public static var loadError: String {
        NSLocalizedString("LOAD_ERROR",
                          tableName: "Rank",
                          bundle: Bundle(for: RankPresenter.self),
                          comment: "Error message when error while loading rank.")
    }
    
    public static var loadErrorMessageDismissAction: String {
        NSLocalizedString("LOAD_ERROR_DISMISS_ACTION",
                          tableName: "Rank",
                          bundle: Bundle(for: RankPresenter.self),
                          comment: "Button to dismiss the load error message.")
    }
    
    public func didLoad(_ records: [PlayerRecord]) {
        rankView.display(RankViewModel(records: records))
    }
    
    public func didLoad(with error: Error) {
        rankView.display(LoadRankErrorViewModel(message: Self.loadError, description: error.localizedDescription, dismissAction: Self.loadErrorMessageDismissAction))
    }
}
