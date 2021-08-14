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
        let nineExistingGoodRecords = Array(repeating: playRecordWith(guessCount: guessCount, guessTime: guessTime), count: 9)
        let badRecord = playRecordWith(guessCount: guessCount+100, guessTime: guessTime+100)
        
        XCTAssertTrue(RankValidationPolicy.validate(badRecord, against: nineExistingGoodRecords), "Expect true even though the new record is bad since there are rank positions available")
    }
    
    func test_validate_deliversFalseWhenRankPositionsUnavailableAndNewRecordNotBeatingOldRecords() {
        let guessCount = 10
        let guessTime = 10.0
        let existingGoodRecords = Array(repeating: playRecordWith(guessCount: guessCount, guessTime: guessTime), count: 10)
        
        let recordWithEqualGuessCountEqualGuessTime = playRecordWith(guessCount: guessCount, guessTime: guessTime)
        XCTAssertFalse(RankValidationPolicy.validate(recordWithEqualGuessCountEqualGuessTime, against: existingGoodRecords), "Expect false when the new record has equal guess count and guess time as the existing records")
        
        let recordWithEqualGuessCountButGreaterGuessTime = playRecordWith(guessCount: guessCount, guessTime: guessTime+1)
        XCTAssertFalse(RankValidationPolicy.validate(recordWithEqualGuessCountButGreaterGuessTime, against: existingGoodRecords), "Expect false when the new record has equal guess count but greater guess time than the existing records")
        
        let recordWithGreaterGuessCountButLessGuessTime = playRecordWith(guessCount: guessCount+1, guessTime: guessTime-1)
        XCTAssertFalse(RankValidationPolicy.validate(recordWithGreaterGuessCountButLessGuessTime, against: existingGoodRecords), "Expect false when the new record has greater guess count even though with less guess time than the existing records")
        
        let recordWithGreaterGuessCountAndEqualGuessTime = playRecordWith(guessCount: guessCount+1, guessTime: guessTime)
        XCTAssertFalse(RankValidationPolicy.validate(recordWithGreaterGuessCountAndEqualGuessTime, against: existingGoodRecords), "Expect false when the new record has greater guess count and equal guess time as the existing records")
        
        let recordWithGreaterGuessCountAndGreaterGuessTime = playRecordWith(guessCount: guessCount+1, guessTime: guessTime+1)
        XCTAssertFalse(RankValidationPolicy.validate(recordWithGreaterGuessCountAndGreaterGuessTime, against: existingGoodRecords), "Expect false when the new record has greater guess count and greater guess time than the existing records")
    }
    
    func test_validate_deliversTrueWhenRankPositionsUnavailableAndNewRecordBeatingOldRecords() {
        let guessCount = 10
        let guessTime = 10.0
        let existingGoodRecords = Array(repeating: playRecordWith(guessCount: guessCount, guessTime: guessTime), count: 10)
        
        let recordWithEqualGuessCountButLessGuessTime = playRecordWith(guessCount: guessCount, guessTime: guessTime-1)
        XCTAssertTrue(RankValidationPolicy.validate(recordWithEqualGuessCountButLessGuessTime, against: existingGoodRecords), "Expect true when the new record has equal guess count but less guess time than the existing records")
        
        let recordWithLessGuessCountButLongerGuessTime = playRecordWith(guessCount: guessCount-1, guessTime: guessTime+1)
        XCTAssertTrue(RankValidationPolicy.validate(recordWithLessGuessCountButLongerGuessTime, against: existingGoodRecords), "Expect true when the new record has less guess count even though with greater guess time than the existing records")
        
        let recordWithLessGuessCountAndEqualGuessTime = playRecordWith(guessCount: guessCount-1, guessTime: guessTime)
        XCTAssertTrue(RankValidationPolicy.validate(recordWithLessGuessCountAndEqualGuessTime, against: existingGoodRecords), "Expect true when the new record has less guess count and equal guess time as the existing records")
        
        let recordWithLessGuessCountAndLessGuessTime = playRecordWith(guessCount: guessCount-1, guessTime: guessTime-1)
        XCTAssertTrue(RankValidationPolicy.validate(recordWithLessGuessCountAndLessGuessTime, against: existingGoodRecords), "Expect true when the new record has less guess count even though with greater guess time than the existing records")
    }
    
    func test_findInvalidRecords_deliversNilWhenExistingRecordCountLessThanMaxRankPositions() {
        let nineRecords = Array(repeating: anyPlayerRecord(), count: 9)
        
        XCTAssertNil(RankValidationPolicy.findInvalidRecords(in: nineRecords))
    }
    
    func test_findInvalidRecords_deliversTheWorstRecordAsTheRecordToBeRemovedWhenExistingRecordCountEqualThanMaxRankPositions() {
        let guessCount = 10
        let guessTime = 10.0
        let nineGoodRecord = Array(repeating: playRecordWith(guessCount: guessCount, guessTime: guessTime), count: 9)
        let oneBadRecord = playRecordWith(guessCount: guessCount+1, guessTime: guessTime)
        var allRecords = [PlayerRecord]()
        allRecords.append(oneBadRecord)
        allRecords.append(contentsOf: nineGoodRecord)
        
        XCTAssertEqual(RankValidationPolicy.findInvalidRecords(in: allRecords), [oneBadRecord])
    }
    
    func test_findInvalidRecords_deliversTheWorstRecordsAsTheRecordsToBeRemovedWhenExistingRecordCountGreaterThanMaxRankPositions() {
        let guessCount = 10
        let guessTime = 10.0
        let oneGoodRecord = playRecordWith(guessCount: guessCount, guessTime: guessTime)
        let nineGoodRecord = Array(repeating: oneGoodRecord, count: 9)
        let oneBadRecord = playRecordWith(guessCount: guessCount+1, guessTime: guessTime)
        let anotherBadRecord = playRecordWith(guessCount: guessCount+2, guessTime: guessTime)
        var allRecords = [PlayerRecord]()
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

    private func playRecordWith(guessCount: Int, guessTime: TimeInterval) -> PlayerRecord {
        .init(playerName: "a name", guessCount: guessCount, guessTime: guessTime)
    }

}
