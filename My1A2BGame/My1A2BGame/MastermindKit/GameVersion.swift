//
//  GameVersion.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/8/31.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import Foundation

public struct GameVersion {
    var digitCount: Int
    var title: String
    var maxGuessCount: Int
    
    static let basic = GameVersion(digitCount: 4, title: "Basic", maxGuessCount: 10)
    
    static let advanced = GameVersion(digitCount: 5, title: "Advanced", maxGuessCount: 15)
}
