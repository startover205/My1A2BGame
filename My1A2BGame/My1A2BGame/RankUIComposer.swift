//
//  RankUIComposer.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/10/2.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit
import Mastermind
import MastermindiOS

public final class RankUIComposer {
    private init() {}
    
    public static func rankComposedWith(
        ranks: [Rank],
        alertHost: UIViewController
    ) -> RankViewController {
        let rankController = makeRankViewController()
        
        let rankViewAdapter = RankViewAdapter(controller: rankController, alertHost: alertHost)
        
        let presentationAdapter = RankPresentationAdapter(ranks: ranks)
        presentationAdapter.presenter = RankPresenter(rankView: rankViewAdapter)
        
        let rankTypeSelectionController = RankTypeSelectionViewController(types: ranks.map(\.title), onChangeSelection: presentationAdapter.loadRank)
        rankController.navigationItem.titleView = rankTypeSelectionController.view
        
        rankController.loadRank = {
            presentationAdapter.loadRank(from: rankTypeSelectionController.view.selectedSegmentIndex)
        }
        
        return rankController
    }
    
    private static func makeRankViewController() -> RankViewController {
        let controller = UIStoryboard(name: "Rank", bundle: .init(for: RankViewController.self)).instantiateViewController(withIdentifier: "RankViewController") as! RankViewController
        return controller
    }
}

private final class RankPresentationAdapter {
    private let ranks: [Rank]
    var presenter: RankPresenter?
    
    init(ranks: [Rank]) {
        self.ranks = ranks
    }
    
    @objc func loadRank(from index: Int) {
        do {
            let records = try ranks[index].loader.load()
            
            presenter?.didLoad(records)
        } catch {
            presenter?.didLoad(with: error)
        }
    }
}

private final class RankViewAdapter: RankView {
    private weak var viewController: RankViewController?
    private weak var alertHost: UIViewController?
    private let guessTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    init(controller: RankViewController, alertHost: UIViewController) {
        self.viewController = controller
        self.alertHost = alertHost
    }
    
    func display(_ viewModel: RankViewModel) {
        if viewModel.records.isEmpty {
            viewController?.tableModel = [RecordCellController(viewModel: PlayerRecordPresenter(formatter: guessTimeFormatter, record: nil).viewModel)]
        } else {
            viewController?.tableModel = viewModel.records.map {
                RecordCellController(viewModel: PlayerRecordPresenter(formatter: guessTimeFormatter, record: $0).viewModel)
            }
        }
    }
    
    func display(_ viewModel: LoadRankErrorViewModel) {
        let alert = UIAlertController(title: viewModel.message, message: viewModel.description, preferredStyle: .alert)
        let action = UIAlertAction(title: viewModel.dismissAction, style: .default, handler: nil)
        
        alert.addAction(action)
        
        alertHost?.present(alert, animated: true)
    }
}
