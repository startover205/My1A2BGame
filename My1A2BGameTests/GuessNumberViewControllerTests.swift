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
    func test_viewDidLoad_fadeOutElmentsAreOpaque() {
        let vc = makeSUT()

        vc.loadViewIfNeeded()
        
        vc.fadeOutElements.forEach {
            XCTAssertTrue($0.alpha == 0)
        }
    }
    
    func test_viewDidLoad_navigiationControllerDelegateIsSelf() {
        
        let navigation = UINavigationController()
        
        let vc = makeSUT(loadView: false)
        
        navigation.setViewControllers([vc], animated: false)


        vc.loadViewIfNeeded()
        
        XCTAssertTrue(vc.navigationController?.delegate === vc)
    }
    
    func test_initGame_availableGuessLabelIsShowingMaxPlayChancesAndLabelColor() {
        let vc = makeSUT()
        
        vc.loadViewIfNeeded()
        
        XCTAssertEqual(vc.availableGuessLabel.textColor, UIColor.label)
        
        let format = NSLocalizedString("You can still guess %d times", comment: "")
        let text = String.localizedStringWithFormat(format, Constants.maxPlayChances)
        
        XCTAssertEqual(vc.availableGuessLabel.text, text)
    }
    
    // MARK: - Helpers
    func makeSUT(loadView: Bool = true) -> GuessNumberViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        let vc = storyboard.instantiateViewController(withIdentifier: "GuessViewController") as! GuessNumberViewController
        if loadView {
            vc.loadViewIfNeeded()
        }
        return vc
    }
}
