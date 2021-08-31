//
//  BasicGame.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/8/31.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import Foundation

public struct BasicGame: GameVersion {
    public let digitCount: Int = 4
    
    public let title: String = "Basic"
    
    public var maxGuessCount: Int = 10
    
    public init() {}
}
