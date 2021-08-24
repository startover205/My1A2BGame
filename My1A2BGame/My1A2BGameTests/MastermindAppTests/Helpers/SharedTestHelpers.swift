//
//  SharedTestHelpers.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/8/24.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import Foundation
import Mastermind

func anyNSError() -> NSError { NSError(domain: "any error", code: 0) }

func anyPlayerRecord() -> PlayerRecord {
    PlayerRecord(playerName: "a name", guessCount: 10, guessTime: 10, timestamp: Date())
}
