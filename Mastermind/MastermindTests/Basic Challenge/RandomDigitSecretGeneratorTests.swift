//
//  RandomDigitSecretGeneratorTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/30.
//

import XCTest
import Mastermind

class RandomDigitSecretGeneratorTests: XCTestCase {
    func test_generate_returnsDigitSecretRandomly() {
        let generateCount = 1000
        var generatedResult = [DigitSecret]()
        
        for _ in 0..<generateCount {
            generatedResult.append(RandomDigitSecretGenerator.generate())
        }
        
        XCTAssertEqual(Set(generatedResult).count, generateCount, accuracy: 150)
    }

    func test_generate_returnsDigitSecretRandomlyWithSuffledDistribution() {
        let generateCount = 1000
        var generatedResult = [DigitSecret]()
        
        for _ in 0..<generateCount {
            generatedResult.append(RandomDigitSecretGenerator.generate())
        }
        
        let total = generatedResult.flatMap { $0.content }.reduce(0, +)
        
        XCTAssertEqual(Double(total), idealTotal(iterateCount: generateCount), accuracy: 1000)
    }
    
    // MARK: - Helpers
    
    private func idealTotal(iterateCount: Int) -> Double {
        4.5 * 4 * Double(iterateCount)
    }
}
