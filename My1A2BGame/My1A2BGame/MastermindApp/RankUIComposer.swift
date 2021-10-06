//
//  RankUIComposer.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/10/2.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit
import Mastermind

public final class RankUIComposer {
    private init() {}
    
    public static func rankComposedWith(requestRecords: @escaping () -> [User], requestAdvancedRecords: @escaping () -> [User]) -> RankViewController {
        let rankController = makeRankViewController(title: "Rank")
        
        let presentationAdapter = RankPresentationAdapter(
            requestRecords: requestRecords,
            requestAdvancedRecord: requestAdvancedRecords)
        presentationAdapter.presenter = RankPresenter(rankView: WeakRefVirtualProxy(rankController))
        
        rankController.onRefresh = presentationAdapter.refresh
        
        return rankController
    }
    
    private static func makeRankViewController(title: String) -> RankViewController {
        let controller = UIStoryboard(name: "Rank", bundle: .init(for: RankViewController.self)).instantiateViewController(withIdentifier: "RankViewController") as! RankViewController
        controller.title = title
        return controller
    }
}

final class RankPresentationAdapter {
    private let requestRecords: (() -> [User])
    private let requestAdvancedRecord: (() -> [User])
    var presenter: RankPresenter?
    
    init(requestRecords: @escaping (() -> [User]), requestAdvancedRecord: @escaping (() -> [User])) {
        self.requestRecords = requestRecords
        self.requestAdvancedRecord = requestAdvancedRecord
    }
    
    func refresh(isAdvancedVersion: Bool) {
        if isAdvancedVersion {
            presenter?.didRefresh(records: requestAdvancedRecord().toModel())
        } else {
            presenter?.didRefresh(records: requestRecords().toModel())
        }
    }
}

private extension Array where Element == User {
    func toModel() -> [PlayerRecord] {
        map {
            .init(playerName: $0.name, guessCount: Int($0.guessTimes), guessTime: $0.spentTime, timestamp: $0.date)
        }
    }
}
