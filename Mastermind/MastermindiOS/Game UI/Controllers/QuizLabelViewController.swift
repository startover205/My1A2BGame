//
//  QuizLabelViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/9/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit

public final class QuizLabelViewController: NSObject {
    @IBOutlet private(set) public weak var quizLabelContainer: UIStackView!
    
    private(set) public var quizLabels = [UILabel]()
    
    public var answer: [Int]!

    public func configureViews() {
        for _ in 0 ..< answer.count {
            let label = makeQuizLabel()
            quizLabelContainer.addArrangedSubview(label)
            quizLabels.append(label)
        }
        hideAnswer()
        
        quizLabelContainer.layoutIfNeeded()
    }
    
    public func hideAnswer() {
        quizLabels.forEach {
            $0.text = "?"
            $0.textColor = .systemRed
        }
    }
    
    public func revealAnswer() {
        answer.enumerated().forEach { index, digit in
            let label = quizLabels[index]
            label.text = digit.description
            label.textColor = #colorLiteral(red: 0.287477035, green: 0.716722175, blue: 0.8960909247, alpha: 1)
        }
    }
    
    private func makeQuizLabel() -> UILabel {
        let label = UILabel()
        label.font = .init(name: "Arial Rounded MT Bold", size: 80)
        label.adjustsFontSizeToFitWidth = true
        return label
    }
}
