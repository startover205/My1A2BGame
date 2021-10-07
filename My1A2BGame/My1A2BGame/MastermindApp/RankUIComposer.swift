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
    
    public static func rankComposedWith(requestRecords: RecordLoader, requestAdvancedRecords: RecordLoader) -> RankViewController {
        let rankController = makeRankViewController(title: "Rank")
        
        let rankViewAdapter = RankViewAdapter(controller: rankController)
        
        let presentationAdapter = RankPresentationAdapter(
            requestRecords: requestRecords,
            requestAdvancedRecord: requestAdvancedRecords)
        presentationAdapter.presenter = RankPresenter(rankView: rankViewAdapter)
        
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
    private let requestRecords: RecordLoader
    private let requestAdvancedRecord: RecordLoader
    var presenter: RankPresenter?
    
    init(requestRecords: RecordLoader, requestAdvancedRecord: RecordLoader) {
        self.requestRecords = requestRecords
        self.requestAdvancedRecord = requestAdvancedRecord
    }
    
    func refresh(isAdvancedVersion: Bool) {
        if isAdvancedVersion {
            presenter?.didRefresh(records: try! requestAdvancedRecord.load())
        } else {
            presenter?.didRefresh(records: try! requestRecords.load())
        }
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
            controller?.tableModels = [PlaceholderRecordCellController()]
        } else {
            controller?.tableModels = viewModel.records.map {
                ModelRecordCellController(model: $0, formatter: guessTimeFormatter)
            }
        }
    }
}
