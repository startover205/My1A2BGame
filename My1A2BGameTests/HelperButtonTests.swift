//
//  HelperButtonTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/6/5.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame

class HelperButtonTests: XCTestCase {
    func test_reset_restoreDefaultBackgroundColor() {
        let sut = HelperButton()
        let defaultColor = sut.backgroundColor
        let newColor: UIColor = defaultColor == .red ? .blue : .red
        sut.backgroundColor = newColor
        
        sut.reset()
        
        XCTAssertEqual(sut.backgroundColor, defaultColor)
    }
    
    func test_toggleColor_changeThreeBackgroundColorsCyclically() {
        let sut = HelperButton()
        var buttonColors = [UIColor]()
        buttonColors.append(sut.backgroundColor!)
        sut.toggleColor()
        buttonColors.append(sut.backgroundColor!)
        sut.toggleColor()
        buttonColors.append(sut.backgroundColor!)
        
        sut.toggleColor()
        XCTAssertEqual(sut.backgroundColor, buttonColors[0])
        sut.toggleColor()
        XCTAssertEqual(sut.backgroundColor, buttonColors[1])
        sut.toggleColor()
        XCTAssertEqual(sut.backgroundColor, buttonColors[2])
    }
}
