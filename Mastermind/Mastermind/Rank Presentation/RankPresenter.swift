//
//  RankPresenter.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/10/7.
//

public final class RankPresenter {
    private let rankView: RankView
    
    public init(rankView: RankView) {
        self.rankView = rankView
    }
    
    public func didLoad(_ records: [PlayerRecord]) {
        rankView.display(RankViewModel(records: records))
    }
}
