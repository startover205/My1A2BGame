//
//  NumberInputViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/9/15.
//  Copyright © 2019 Ming-Ta Yang. All rights reserved.
//

import UIKit

public protocol NumberInputViewControllerDelegate {
    func numberInputViewController(_ numberInputViewController: NumberInputViewController, didFinishEntering numberTexts: [String])
}

public class NumberInputViewController: UIViewController {
    
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    
    @IBOutlet private(set) public weak var digitContainer: UIStackView!
    @IBOutlet private(set) public weak var oneButton: UIButton!
    @IBOutlet private(set) public weak var twoButton: UIButton!
    @IBOutlet private(set) public weak var threeButton: UIButton!
    @IBOutlet private(set) public weak var fourButton: UIButton!
    @IBOutlet private(set) public weak var fiveButton: UIButton!
    @IBOutlet private(set) public weak var sixButton: UIButton!
    @IBOutlet private(set) public weak var sevenButton: UIButton!
    @IBOutlet private(set) public weak var eightButton: UIButton!
    @IBOutlet private(set) public weak var nineButton: UIButton!
    @IBOutlet private(set) public weak var zeroButton: UIButton!
    @IBOutlet private(set) public weak var deleteButton: UIButton!
    @IBOutlet private(set) public weak var clearButton: UIButton!
    private var digitLabels = [UILabel]()
    private var digitButtons = [UIButton]()
    private var allButtons = [UIButton]()
    
    var currentDigit = 0
    var canTap = true
    public var digitCount: Int = 4
    public var delegate: NumberInputViewControllerDelegate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDigitView()
        
        configureButtons()
        
        resetPanel()
    }
    
    private func configureButtons() {
        digitButtons.append(oneButton)
        digitButtons.append(twoButton)
        digitButtons.append(threeButton)
        digitButtons.append(fourButton)
        digitButtons.append(fiveButton)
        digitButtons.append(sixButton)
        digitButtons.append(sevenButton)
        digitButtons.append(eightButton)
        digitButtons.append(nineButton)
        digitButtons.append(zeroButton)
        
        digitButtons.forEach {
            $0.layer.shadowOffset = .init(width: 0, height: 2)
            $0.layer.shadowRadius = 0
            $0.layer.shadowOpacity = 0.4
        }
        
        allButtons.append(contentsOf: digitButtons)
        allButtons.append(deleteButton)
        allButtons.append(clearButton)
        
        allButtons.forEach {
            $0.layer.cornerRadius = 4
            
            $0.titleLabel?.minimumScaleFactor = 0.5
            $0.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    
    private func configureDigitView() {
        for _ in 0..<digitCount {
            let digitViewContainer = UIStackView()
            digitViewContainer.alignment = .center
            digitViewContainer.distribution = .fill
            digitViewContainer.axis = .vertical
            digitViewContainer.spacing = -32
            
            let digitLabel = makeDigitLabel()
            digitLabels.append(digitLabel)
            digitViewContainer.addArrangedSubview(digitLabel)
            digitViewContainer.addArrangedSubview(makeUnderscoreLabel())
            
            digitContainer.addArrangedSubview(digitViewContainer)
        }
    }
    
    private func makeDigitLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 50)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 32).isActive = true
        label.heightAnchor.constraint(equalToConstant: 64).isActive = true
        label.text = "0"
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.sizeToFit()
        return label
    }
    
    private func makeUnderscoreLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 50)
        label.text = "_"
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.sizeToFit()
        return label
    }
    
    func resetPanel() {
        clearAllText()
        enableAllButton()
        
        currentDigit = 0
        
        canTap = true
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        resetPanel()
    }
    
    @IBAction func clearBtnPressed(_ sender: Any) {
        clearAllText()
        enableAllButton()
        
        currentDigit = 0
        
        canTap = true
    }
    @IBAction func deleteBtnPressed(_ sender: Any) {
        if currentDigit > 0 {
            enableNumberBtn(text: digitLabels[currentDigit-1].text)
            digitLabels[currentDigit-1].text = ""
            
            currentDigit -= 1
        }
    }
    
    @IBAction func numberBtnPressed(_ sender: UIButton) {
        guard canTap else { return }
        
        digitLabels[currentDigit].text = sender.titleLabel!.text
        
        sender.isEnabled = false
        
        currentDigit += 1
        
        if currentDigit == digitLabels.count {
            canTap = false
            guess()
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Private
private extension NumberInputViewController {
    func guess() {
        var texts = [String]()
        for label in self.digitLabels {
            texts.append(label.text!)
        }
        
        delegate?.numberInputViewController(self, didFinishEntering: texts)
    }
    
    func enableNumberBtn(text: String?){
        guard let text = text else { return }
        guard let number = Int(text) else {
            assertionFailure()
            return }
        switch number {
        case 0:
            zeroButton.isEnabled = true
        case 1:
            oneButton.isEnabled = true
        case 2:
            twoButton.isEnabled = true
        case 3:
            threeButton.isEnabled = true
        case 4:
            fourButton.isEnabled = true
        case 5:
            fiveButton.isEnabled = true
        case 6:
            sixButton.isEnabled = true
        case 7:
            sevenButton.isEnabled = true
        case 8:
            eightButton.isEnabled = true
        case 9:
            nineButton.isEnabled = true
        default:
            break
        }
    }
    func enableAllButton() {
        zeroButton.isEnabled = true
        oneButton.isEnabled = true
        twoButton.isEnabled = true
        threeButton.isEnabled = true
        fourButton.isEnabled = true
        fiveButton.isEnabled = true
        sixButton.isEnabled = true
        sevenButton.isEnabled = true
        eightButton.isEnabled = true
        nineButton.isEnabled = true
    }
    func clearAllText() {
        for label in digitLabels {
            label.text = ""
        }
    }
}
