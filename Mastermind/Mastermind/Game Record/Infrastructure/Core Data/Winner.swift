//
//  Winner+CoreDataClass.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/14.
//
//

import Foundation
import CoreData

@objc(Winner)
public class Winner: NSManagedObject {
    @NSManaged public var date: Date
    @NSManaged public var guessTimes: Int16
    @NSManaged public var name: String
    @NSManaged public var spentTime: Double
}
