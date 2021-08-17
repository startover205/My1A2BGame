//
//  ManagedRecord.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/17.
//

import CoreData

public protocol ManagedRecord: NSManagedObject {
    var name: String? { get set }
    var guessTimes: Int16 { get set }
    var spentTime: Double { get set }
    var date: Date? { get set }
}

extension Winner: ManagedRecord { }

extension AdvancedWinner: ManagedRecord { }
