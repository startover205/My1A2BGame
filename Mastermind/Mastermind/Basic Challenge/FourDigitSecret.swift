//
//  FourDigitSecret.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/30.
//

import Foundation

public struct FourDigitSecret {
    let content: [Int]
    
    static let digitCount = 4
    
    public init?(first: Int, second: Int, third: Int, fourth: Int) {
        content = [first, second, third, fourth]
        
        guard Set(content).count == Self.digitCount else { return nil }
        
        for digit in content {
            if digit < 0 || digit > 9 { return nil }
        }
    }
}
