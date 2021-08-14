//
//  AdvancedWinner+CoreDataClass.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/14.
//
//

import Foundation
import CoreData

@objc(AdvancedWinner)
class AdvancedWinner: NSManagedObject {
    @NSManaged var date: Date?
    @NSManaged var guessTimes: Int16
    @NSManaged var name: String?
    @NSManaged var spentTime: Double
}
