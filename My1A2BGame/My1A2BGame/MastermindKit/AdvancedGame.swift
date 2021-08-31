//
//  AdvancedGame.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/8/31.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import Foundation

public struct AdvancedGame: GameVersion {
    public let digitCount: Int = 5
    
    public let title: String = "Advanced"
    
    public var maxGuessCount: Int = 15
    
    public init() {}
}
