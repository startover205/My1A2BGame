//
//  GuessPadViewControllerSnapshotTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/7/30.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame

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
    
    // MARK: - Helpers
    
    func makeSUT(digitCount: Int) -> UIViewController {
        let controller = GameUIComposer.makeInputPadUI(digitCount: digitCount)
        controller.loadViewIfNeeded()
        return controller
    }
}
