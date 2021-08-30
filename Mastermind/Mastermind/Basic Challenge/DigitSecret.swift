//
//  DigitSecret.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/30.
//

import Foundation

public struct DigitSecret: Hashable {
    public let content: [Int]
    
    public init?(digits: [Int]) {
        guard Set(digits).count == digits.count else { return nil }
        
        for digit in digits {
            if digit < 0 || digit > 9 { return nil }
        }
        
        content = digits
    }
}
