//
//  RankUIComposer.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/10/2.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit

public final class RankUIComposer {
    private init() {}
    
    public static func rankComposedWith(requestRecords: @escaping () -> [User], requestAdvancedRecords: @escaping () -> [User]) -> RankViewController {
        let rankController = makeRankViewController(title: "Rank")
        rankController.requestRecords = requestRecords
        rankController.requestAdvancedRecord = requestAdvancedRecords
        
        return rankController
    }
    
    private static func makeRankViewController(title: String) -> RankViewController {
        let controller = UIStoryboard(name: "Rank", bundle: .init(for: RankViewController.self)).instantiateViewController(withIdentifier: "RankViewController") as! RankViewController
        controller.title = title
        return controller
    }
}
