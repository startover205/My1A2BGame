//
//  RankValidationPolicyTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/8/14.
//

import XCTest
@testable import Mastermind

class RankValidationPolicyTests: XCTestCase {
    func test_validate_deliversTrueOnRankPositionsAvailable() {
        let guessCount = 10
        let guessTime = 10.0
        let nineExistingGoodRecords = Array(repeating: playerRecordWith(guessCount: guessCount, guessTime: guessTime), count: 9)
        let badScore = (guessCount + 100, guessTime + 100)
        
        XCTAssertTrue(RankValidationPolicy.validate(badScore, against: nineExistingGoodRecords), "Expect true even though the new record is bad since there are rank positions available")
    }
    
    func test_validate_deliversFalseWhenRankPositionsUnavailableAndNewRecordNotBeatingOldRecords() {
        let guessCount = 10
        let guessTime = 10.0
        let existingGoodRecords = Array(repeating: playerRecordWith(guessCount: guessCount, guessTime: guessTime), count: 10)
        
        let scoreWithEqualGuessCountEqualGuessTime = (guessCount, guessTime)
        XCTAssertFalse(RankValidationPolicy.validate(scoreWithEqualGuessCountEqualGuessTime, against: existingGoodRecords), "Expect false when the new record has equal guess count and guess time as the existing records")
        
        let scoreWithEqualGuessCountButGreaterGuessTime = (guessCount: guessCount, guessTime: guessTime+1)
        XCTAssertFalse(RankValidationPolicy.validate(scoreWithEqualGuessCountButGreaterGuessTime, against: existingGoodRecords), "Expect false when the new record has equal guess count but greater guess time than the existing records")
        
        let scoreWithGreaterGuessCountButLessGuessTime = (guessCount: guessCount+1, guessTime: guessTime-1)
        XCTAssertFalse(RankValidationPolicy.validate(scoreWithGreaterGuessCountButLessGuessTime, against: existingGoodRecords), "Expect false when the new record has greater guess count even though with less guess time than the existing records")
        
        let scoreWithGreaterGuessCountAndEqualGuessTime = (guessCount: guessCount+1, guessTime: guessTime)
        XCTAssertFalse(RankValidationPolicy.validate(scoreWithGreaterGuessCountAndEqualGuessTime, against: existingGoodRecords), "Expect false when the new record has greater guess count and equal guess time as the existing records")
        
        let scoreWithGreaterGuessCountAndGreaterGuessTime = (guessCount: guessCount+1, guessTime: guessTime+1)
        XCTAssertFalse(RankValidationPolicy.validate(scoreWithGreaterGuessCountAndGreaterGuessTime, against: existingGoodRecords), "Expect false when the new record has greater guess count and greater guess time than the existing records")
    }
    
    func test_validate_deliversTrueWhenRankPositionsUnavailableAndNewRecordBeatingOldRecords() {
        let guessCount = 10
        let guessTime = 10.0
        let existingGoodRecords = Array(repeating: playerRecordWith(guessCount: guessCount, guessTime: guessTime), count: 10)
        
        let scoreWithEqualGuessCountButLessGuessTime = (guessCount: guessCount, guessTime: guessTime-1)
        XCTAssertTrue(RankValidationPolicy.validate(scoreWithEqualGuessCountButLessGuessTime, against: existingGoodRecords), "Expect true when the new record has equal guess count but less guess time than the existing records")
        
        let scoreWithLessGuessCountButLongerGuessTime = (guessCount: guessCount-1, guessTime: guessTime+1)
        XCTAssertTrue(RankValidationPolicy.validate(scoreWithLessGuessCountButLongerGuessTime, against: existingGoodRecords), "Expect true when the new record has less guess count even though with greater guess time than the existing records")
        
        let scoreWithLessGuessCountAndEqualGuessTime = (guessCount: guessCount-1, guessTime: guessTime)
        XCTAssertTrue(RankValidationPolicy.validate(scoreWithLessGuessCountAndEqualGuessTime, against: existingGoodRecords), "Expect true when the new record has less guess count and equal guess time as the existing records")
        
        let scoreWithLessGuessCountAndLessGuessTime = (guessCount: guessCount-1, guessTime: guessTime-1)
        XCTAssertTrue(RankValidationPolicy.validate(scoreWithLessGuessCountAndLessGuessTime, against: existingGoodRecords), "Expect true when the new record has less guess count even though with greater guess time than the existing records")
    }
    
    func test_findInvalidRecords_deliversNilWhenExistingRecordCountLessThanMaxRankPositions() {
        let nineRecords = Array(repeating: anyPlayerRecord().local, count: 9)
        
        XCTAssertNil(RankValidationPolicy.findInvalidRecords(in: nineRecords))
    }
    
    func test_findInvalidRecords_deliversTheWorstRecordAsTheRecordToBeRemovedWhenExistingRecordCountEqualThanMaxRankPositions() {
        let guessCount = 10
        let guessTime = 10.0
        let nineGoodRecord = Array(repeating: playerRecordWith(guessCount: guessCount, guessTime: guessTime), count: 9)
        let oneBadRecord = playerRecordWith(guessCount: guessCount+1, guessTime: guessTime)
        var allRecords = [LocalPlayerRecord]()
        allRecords.append(oneBadRecord)
        allRecords.append(contentsOf: nineGoodRecord)
        
        XCTAssertEqual(RankValidationPolicy.findInvalidRecords(in: allRecords), [oneBadRecord])
    }
    
    func test_findInvalidRecords_deliversTheWorstRecordsAsTheRecordsToBeRemovedWhenExistingRecordCountGreaterThanMaxRankPositions() {
        let guessCount = 10
        let guessTime = 10.0
        let oneGoodRecord = playerRecordWith(guessCount: guessCount, guessTime: guessTime)
        let nineGoodRecord = Array(repeating: oneGoodRecord, count: 9)
        let oneBadRecord = playerRecordWith(guessCount: guessCount+1, guessTime: guessTime)
        let anotherBadRecord = playerRecordWith(guessCount: guessCount+2, guessTime: guessTime)
        var allRecords = [LocalPlayerRecord]()
        allRecords.append(contentsOf: nineGoodRecord)
        allRecords.append(oneGoodRecord)
        allRecords.append(oneBadRecord)
        allRecords.append(anotherBadRecord)
        
        XCTAssertEqual(RankValidationPolicy.findInvalidRecords(in: allRecords)?.count, 3)
        XCTAssertEqual(RankValidationPolicy.findInvalidRecords(in: allRecords)?.contains(oneGoodRecord), true)
        XCTAssertEqual(RankValidationPolicy.findInvalidRecords(in: allRecords)?.contains(oneBadRecord), true)
        XCTAssertEqual(RankValidationPolicy.findInvalidRecords(in: allRecords)?.contains(anotherBadRecord), true)
    }
    
    // MARK: - Helpers
    
    private func playerRecordWith(guessCount: Int, guessTime: TimeInterval) -> LocalPlayerRecord {
        .init(playerName: "a name", guessCount: guessCount, guessTime: guessTime, timestamp: Date())
    }
}
