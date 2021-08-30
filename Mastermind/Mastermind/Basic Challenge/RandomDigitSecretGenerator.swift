//
//  RandomDigitSecretGenerator.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/30.
//

import Foundation
import GameKit

public final class RandomDigitSecretGenerator {
    public static func generate() -> FourDigitSecret {
        var digits = [Int]()

        let distribution = GKShuffledDistribution(lowestValue: 0, highestValue: 9)
        
        for _ in 0..<4 {
            digits.append(distribution.nextInt())
        }
        
        return FourDigitSecret(digits: digits)!
    }
}
