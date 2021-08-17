//
//  GuessNumberViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/6/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
@testable import My1A2BGame

class GuessNumberViewControllerTests: XCTestCase {
    func test_load_fadeOutElmentsAreOpaque() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        let vc = storyboard.instantiateViewController(withIdentifier: "GuessViewController") as! GuessNumberViewController

        vc.loadViewIfNeeded()
        
        vc.fadeOutElements.forEach {
            XCTAssertTrue($0.alpha == 0)
        }
    }
}
