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
    
    static func rank() -> RankViewController {
        makeRankViewController(title: "Rank")
    }
    
    private static func makeRankViewController(title: String) -> RankViewController {
        let controller = UIStoryboard(name: "Rank", bundle: .init(for: RankViewController.self)).instantiateViewController(withIdentifier: "RankViewController") as! RankViewController
        controller.title = title
        return controller
    }
}
