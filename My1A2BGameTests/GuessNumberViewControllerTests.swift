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
        makeSUT().fadeOutElements.forEach {
            XCTAssertTrue($0.alpha == 0)
        }
    }
    
    func test_viewDidLoad_navigiationControllerDelegateIsSelf() {
        
        let navigation = UINavigationController()
        
        let sut = makeSUT(loadView: false)
        
        navigation.setViewControllers([sut], animated: false)

        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.navigationController?.delegate === sut)
    }
    
    func test_initGame_availableGuessLabelIsShowingMaxPlayChancesAndLabelColor() {
        let sut = makeSUT()
        let format = NSLocalizedString("You can still guess %d times", comment: "")
        let text = String.localizedStringWithFormat(format, Constants.maxPlayChances)
        
        XCTAssertEqual(sut.availableGuessLabel.text, text)
        XCTAssertEqual(sut.availableGuessLabel.textColor, UIColor.label)
    }
    
    func test_viewWillAppear_fadeOutElmentsAreVisible() {
        let sut = makeSUT()

        sut.viewWillAppear(false)
        
        sut.fadeOutElements.forEach {
            XCTAssertEqual($0.alpha, 1)
        }
    }
    
    func test_viewWillAppear_voiceSwitchStatusAccordingToUserDefaultSetting() {
        let sut = makeSUT()
        UserDefaults.standard.setValue(true, forKey: UserDefaults.Key.voicePromptsSwitch)
        
        sut.viewWillAppear(false)
        
        XCTAssertEqual(sut.voiceSwitch.isOn, true)

        UserDefaults.standard.setValue(false, forKey: UserDefaults.Key.voicePromptsSwitch)
        
        sut.viewWillAppear(false)

        XCTAssertEqual(sut.voiceSwitch.isOn, false)
    }
    
    func test_viewDidLoad_helperViewHidden() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.helperView.isHidden)
    }
    
    func test_helperBtnPressed_toggleHelperViewDisplay() {
        let sut = makeSUT()
        
        sut.helperBtnPressed(sut)
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            XCTAssertEqual(sut.helperView.isHidden, false)
            
            sut.helperBtnPressed(sut)
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                XCTAssertEqual(sut.helperView.isHidden, true)
            }
        }
    }
    
    // MARK: - Helpers
    func makeSUT(loadView: Bool = true) -> GuessNumberViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        let sut = storyboard.instantiateViewController(withIdentifier: "GuessViewController") as! GuessNumberViewController
        if loadView {
            sut.loadViewIfNeeded()
        }
        return sut
    }
}
