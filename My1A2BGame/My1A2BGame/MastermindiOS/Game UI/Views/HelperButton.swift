//
//  HelperButton.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/9/18.
//  Copyright © 2019 Ming-Ta Yang. All rights reserved.
//

import UIKit

public class HelperButton: UIButton {
    private enum FilterState {
        case first
        case second
        case third
    }
    
    private let defaultState: FilterState = .first
    
    private lazy var filterState: FilterState = defaultState
    
    private var filterColor: UIColor {
        switch filterState {
        case .first:
            return #colorLiteral(red: 0.5176470588, green: 0.5176470588, blue: 0.537254902, alpha: 1)
        case .second:
            return #colorLiteral(red: 0, green: 0.4392156863, blue: 0.9607843137, alpha: 1)
        case .third:
            return #colorLiteral(red: 0.9607843137, green: 0.7607843137, blue: 0, alpha: 1)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    private func configureView() {
        backgroundColor = filterColor

        addTarget(self, action: #selector(toggleColor), for: .touchUpInside)
    }
    
    public func reset() {
        filterState = defaultState
        backgroundColor = filterColor
    }
    
    @objc
    public func toggleColor() {
        switch filterState {
               case .first:
                filterState = .second
               case .second:
                filterState = .third
               case .third:
                filterState = .first
               }
        backgroundColor = filterColor
    }
}
