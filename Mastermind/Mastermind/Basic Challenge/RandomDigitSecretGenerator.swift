//
//  RandomDigitSecretGenerator.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/30.
//

import Foundation
import GameKit

public final class RandomDigitSecretGenerator {
    private init() {}
    
    public static func generate(digitCount: Int) -> DigitSecret {
        var digits = [Int]()

        let distribution = GKShuffledDistribution(lowestValue: 0, highestValue: 9)
        
        for _ in 0..<digitCount {
            digits.append(distribution.nextInt())
        }
        
        return DigitSecret(digits: digits)!
    }
}
