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
    
    public static func rankComposedWith(requestRecords: RecordLoader, requestAdvancedRecords: RecordLoader) -> RankViewController {
        let rankController = makeRankViewController(title: "Rank")
        
        let rankViewAdapter = RankViewAdapter(controller: rankController)
        
        let presentationAdapter = RankPresentationAdapter(
            requestRecords: requestRecords,
            requestAdvancedRecord: requestAdvancedRecords)
        presentationAdapter.presenter = RankPresenter(rankView: rankViewAdapter)
        
        rankController.loadRank = presentationAdapter.loadRank
        
        return rankController
    }
    
    private static func makeRankViewController(title: String) -> RankViewController {
        let controller = UIStoryboard(name: "Rank", bundle: .init(for: RankViewController.self)).instantiateViewController(withIdentifier: "RankViewController") as! RankViewController
        controller.title = title
        return controller
    }
}

final class RankPresentationAdapter {
    private let requestRecords: RecordLoader
    private let requestAdvancedRecord: RecordLoader
    var presenter: RankPresenter?
    
    init(requestRecords: RecordLoader, requestAdvancedRecord: RecordLoader) {
        self.requestRecords = requestRecords
        self.requestAdvancedRecord = requestAdvancedRecord
    }
    
    func loadRank(isAdvancedVersion: Bool) {
        let records = isAdvancedVersion ? try! requestAdvancedRecord.load() : try! requestRecords.load()
        
        presenter?.didLoad(records)
    }
}

final class RankViewAdapter: RankView {
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
