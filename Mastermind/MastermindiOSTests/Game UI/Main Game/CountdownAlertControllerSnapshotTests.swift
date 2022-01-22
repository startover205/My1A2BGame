//
//  CountdownAlertControllerSnapshotTests.swift
//  MastermindiOSTests
//
//  Created by Ming-Ta Yang on 2022/1/20.
//

import XCTest
import MastermindiOS

class CountdownAlertControllerSnapshotTests: XCTestCase {
    func test_appearance() {
        let sut = makeSUT()
        
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "APPEARANCE_light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "APPEARANCE_dark")
    }
    
    // MARK: - Helpers
    
    func makeSUT() -> CountdownAlertController {
        let controller = CountdownAlertController(title: "a title", message: "a message", cancelAction: "cancel", countdownTime: 10)
        
        controller.loadViewIfNeeded()
        
//        controller.confirmButton.setImage(UIImage.make(withColor: .red), for: .normal)
        
        return controller
    }
}
//
//private extension GuessNumberViewController {
//    func simulateGameWithOneGuess() {
//        hintViewController.hintLabel.isHidden = false
//        hintViewController.hintLabel.text = "3210          0A4B"
//    }
//
//    func simulateGameWithTwoGuess() {
//        hintViewController.hintLabel.isHidden = false
//        hintViewController.hintLabel.text = "3210          0A4B"
//        hintViewController.hintTextView.text = "\n3210          0A4B"
//    }
//
//    func simulateGameEnd() {
//        guessButton.isHidden = true
//        giveUpButton.isHidden = true
//        restartButton.isHidden = false
//        helperViewController?.hideView()
//        quizLabelViewController.revealAnswer()
//    }
//
//    func simulateTurnOnHelper() {
//        helperViewController.helperBtnPressed(self)
//    }
//}


private extension UIImage {
            static func make(withColor color: UIColor) -> UIImage {
                let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
                UIGraphicsBeginImageContext(rect.size)
                let context = UIGraphicsGetCurrentContext()!
                context.setFillColor(color.cgColor)
                context.fill(rect)
                let img = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return img!
            }
}
