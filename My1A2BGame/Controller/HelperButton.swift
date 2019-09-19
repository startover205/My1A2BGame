//
//  HelperButton.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/9/18.
//  Copyright © 2019 Ming-Ta Yang. All rights reserved.
//

import UIKit

class HelperButton: UIButton {
    
    var isFiltered = false
    
    let filteredColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    let defilteredColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)

    func reset(){
        isFiltered = false
        backgroundColor = defilteredColor
    }
    func toggleColor(){
        isFiltered = !isFiltered
        backgroundColor = isFiltered ? filteredColor: defilteredColor
    }
}

// MARK: - Private
private extension HelperButton {
    
}
