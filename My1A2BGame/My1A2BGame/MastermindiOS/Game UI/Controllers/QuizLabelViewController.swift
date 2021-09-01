//
//  QuizLabelViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/9/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit

public final class QuizLabelViewController: NSObject {
    @IBOutlet weak var quizLabelContainer: UIStackView!
    
    public var digitCount: Int!
    
    private(set) public var quizLabels = [UILabel]()

    func configureViews() {
        for _ in 0 ..< digitCount {
            let label = makeQuizLabel()
            quizLabelContainer.addArrangedSubview(label)
            quizLabels.append(label)
        }
        resetQuizLabels()
        
        quizLabelContainer.layoutIfNeeded()
    }
    
    func resetQuizLabels() {
        quizLabels.forEach {
            $0.text = "?"
            $0.textColor = .systemRed
        }
    }
    
    func reveal(answer: [String]) {
        for i in 0..<digitCount{
            quizLabels[i].textColor = #colorLiteral(red: 0.287477035, green: 0.716722175, blue: 0.8960909247, alpha: 1)
            quizLabels[i].text = answer[i]
        }
    }

    
    private func makeQuizLabel() -> UILabel {
        let label = UILabel()
        label.font = .init(name: "Arial Rounded MT Bold", size: 80)
        label.adjustsFontSizeToFitWidth = true
        return label
    }
}
