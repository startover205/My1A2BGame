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

public struct Rank {
    public let title: String
    public let loader: RecordLoader
    
    public init(title: String, loader: RecordLoader) {
        self.title = title
        self.loader = loader
    }
}

public final class RankTypeSelectionViewController {
    private(set) lazy var view: UISegmentedControl = {
        let view = UISegmentedControl(items: types)
        view.selectedSegmentIndex = 0
        view.addTarget(self, action: #selector(didChangeSelection), for: .valueChanged)
        return view
    }()
    
    private let types: [String]
    private let onChangeSelection: (Int) -> Void?
    
    public init(types: [String], onChangeSelection: @escaping (Int) -> Void) {
        self.types = types
        self.onChangeSelection = onChangeSelection
    }
    
    @objc func didChangeSelection(sender: UISegmentedControl) {
        onChangeSelection(sender.selectedSegmentIndex)
    }
}


public final class RankUIComposer {
    private init() {}
    
    public static func rankComposedWith(ranks: [Rank]) -> RankViewController {
        let rankController = makeRankViewController()
        
        let rankViewAdapter = RankViewAdapter(controller: rankController)
        
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
        let records = try! ranks[index].loader.load()
        
        presenter?.didLoad(records)
    }
}

private final class RankViewAdapter: RankView {
    private weak var controller: RankViewController?
    private let guessTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    init(controller: RankViewController) {
        self.controller = controller
    }
    
    func display(_ viewModel: RankViewModel) {
        if viewModel.records.isEmpty {
            controller?.tableModel = [RecordCellController(viewModel: PlayerRecordPresenter(formatter: guessTimeFormatter, record: nil).viewModel)]
        } else {
            controller?.tableModel = viewModel.records.map {
                RecordCellController(viewModel: PlayerRecordPresenter(formatter: guessTimeFormatter, record: $0).viewModel)
            }
        }
    }
}
