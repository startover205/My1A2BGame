//
//  GuessPadViewControllerSnapshotTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/7/30.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import MastermindiOS

class GuessPadViewControllerSnapshotTests: XCTestCase {
    
    func test_emptyInputWithFourDigit() {
        let sut = makeSUT(digitCount: 4)
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_INPUT_PAD_FOUR_DIGIT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_INPUT_PAD_FOUR_DIGIT_dark")
    }
    
    func test_emptyInputWithFiveDigit() {
        let sut = makeSUT(digitCount: 5)
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_INPUT_PAD_FIVE_DIGIT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_INPUT_PAD_FIVE_DIGIT_dark")
    }
    
    func test_oneInputWithFourDigit() {
        let sut = makeSUT(digitCount: 4)
        
        sut.pressNumberOne()
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "ONE_INPUT_PAD_FOUR_DIGIT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "ONE_INPUT_PAD_FOUR_DIGIT_dark")
    }
    
    func test_oneInputWithFiveDigit() {
        let sut = makeSUT(digitCount: 5)
        
        sut.pressNumberOne()
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "ONE_INPUT_PAD_FIVE_DIGIT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "ONE_INPUT_PAD_FIVE_DIGIT_dark")
    }
    
    func test_twoInputWithFourDigit() {
        let sut = makeSUT(digitCount: 4)
        
        sut.pressNumberOne()
        sut.pressNumberTwo()
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "TWO_INPUT_PAD_FOUR_DIGIT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "TWO_INPUT_PAD_FOUR_DIGIT_dark")
    }
    
    func test_twoInputWithFiveDigit() {
        let sut = makeSUT(digitCount: 5)
        
        sut.pressNumberOne()
        sut.pressNumberTwo()
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "TWO_INPUT_PAD_FIVE_DIGIT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "TWO_INPUT_PAD_FIVE_DIGIT_dark")
    }
    
    func test_fullInputWithFourDigit() {
        let sut = makeSUT(digitCount: 4)
        
        sut.pressNumberOne()
        sut.pressNumberTwo()
        sut.pressNumberThree()
        sut.pressNumberFour()
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FULL_INPUT_PAD_FOUR_DIGIT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FULL_INPUT_PAD_FOUR_DIGIT_dark")
    }
    
    func test_fullInputWithFiveDigit() {
        let sut = makeSUT(digitCount: 5)
        
        sut.pressNumberOne()
        sut.pressNumberTwo()
        sut.pressNumberThree()
        sut.pressNumberFour()
        sut.pressNumberFive()
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FULL_INPUT_PAD_FIVE_DIGIT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FULL_INPUT_PAD_FIVE_DIGIT_dark")
    }
    
    // MARK: - Helpers
    
    func makeSUT(digitCount: Int) -> GuessPadViewController {
        let bundle = Bundle(for: GuessPadViewController.self)
        let storyboard = UIStoryboard(name: "Game", bundle: bundle)
        let controller = storyboard.instantiateViewController(identifier: "GuessPadViewController") as! GuessPadViewController
        controller.loadViewIfNeeded()
        controller.digitCount = digitCount
        return controller
    }
}

private extension GuessPadViewController {
    func pressNumberOne() { oneButton.simulateTap() }
    
    func pressNumberTwo() { twoButton.simulateTap() }
    
    func pressNumberThree() { threeButton.simulateTap() }
    
    func pressNumberFour() { fourButton.simulateTap() }
    
    func pressNumberFive() { fiveButton.simulateTap() }
}