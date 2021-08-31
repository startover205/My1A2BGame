//
//  GameVersion.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/8/31.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import Foundation

public protocol GameVersion {
    var digitCount: Int { get }
    var title: String { get }
    var maxGuessCount: Int { get }
}
