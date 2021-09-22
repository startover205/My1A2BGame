//
//  MatchResult.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/9/22.
//

import Foundation

public struct MatchResult: Equatable {
    public let bulls: Int
    public let cows: Int
    public let correct: Bool
    
    public init(bulls: Int, cows: Int, correct: Bool) {
        self.bulls = bulls
        self.cows = cows
        self.correct = correct
    }
}
