//
//  HelperButtonTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/6/5.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest

class HelperButtonTests: XCTestCase {
    func test_reset_restoreDefaultBackgroundColor() {
        let sut = HelperButton()
        let defaultColor = sut.backgroundColor
        
        sut.backgroundColor = sut.newBackgroundColor()
        
        sut.reset()
        
        XCTAssertEqual(sut.backgroundColor, defaultColor, "Expect reset to default color after reset")
    }
    
    func test_onTap_changeThreeBackgroundColorsCyclically() {
        let sut = HelperButton()
        
        let firstColor = sut.backgroundColor
        
        sut.simulateTap()
        let secondColor = sut.backgroundColor
        XCTAssertNotEqual(firstColor, secondColor, "Expect the color changed after tap")
        
        sut.simulateTap()
        let thirdColor = sut.backgroundColor
        XCTAssertNotEqual(secondColor, thirdColor, "Expect the color changed after tap")
        XCTAssertNotEqual(firstColor, thirdColor, "Expect the first color is different from the first color")
        
        sut.simulateTap()
        XCTAssertEqual(sut.backgroundColor, firstColor, "Expect the color changed back to the first color after a whole cycle")
    }
}

private extension HelperButton {
    func newBackgroundColor() -> UIColor { backgroundColor?.withAlphaComponent(0.5) ?? .red }
}
