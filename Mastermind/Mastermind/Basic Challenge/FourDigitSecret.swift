//
//  FourDigitSecret.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/30.
//

import Foundation

public struct FourDigitSecret: Hashable {
    public let content: [Int]
    
    static let digitCount = 4
    
    public init?(digits: [Int]) {
        guard digits.count == Self.digitCount else { return nil }
        
        guard Set(digits).count == Self.digitCount else { return nil }
        
        for digit in digits {
            if digit < 0 || digit > 9 { return nil }
        }
        
        content = digits
    }
}
