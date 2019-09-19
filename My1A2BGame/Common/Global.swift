//
//  Global.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/3/28.
//  Copyright © 2019年 Ming-Ta Yang. All rights reserved.
//

import Foundation

var winnerCoreDataManager: CoreDataManager = CoreDataManager<Winner>(momdFilename: "Model", entityName: "Winner", sortDescriptors: [NSSortDescriptor(key: "guessTimes", ascending: true), NSSortDescriptor(key: "spentTime", ascending: true), NSSortDescriptor(key: "date", ascending: true)])

var advancedWinnerCoreDataManager: CoreDataManager = CoreDataManager<AdvancedWinner>(momdFilename: "ModelAdvanced", entityName: "AdvancedWinner", sortDescriptors: [NSSortDescriptor(key: "guessTimes", ascending: true), NSSortDescriptor(key: "spentTime", ascending: true), NSSortDescriptor(key: "date", ascending: true)])

func print(_ items: Any...) {
    #if DEBUG
    Swift.print(items[0])
    #endif
}
