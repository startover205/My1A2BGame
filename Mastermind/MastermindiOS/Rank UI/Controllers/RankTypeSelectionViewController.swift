//
//  RankTypeSelectionViewController.swift
//  MastermindiOS
//
//  Created by Ming-Ta Yang on 2021/10/14.
//

import UIKit

public final class RankTypeSelectionViewController {
    private(set) public lazy var view: UISegmentedControl = {
        let view = UISegmentedControl(items: types)
        view.selectedSegmentIndex = 0
        view.addTarget(self, action: #selector(didChangeSelection), for: .valueChanged)
        return view
    }()
    
    private let types: [String]
    private let onChangeSelection: (Int) -> Void?
    
    public init(types: [String], onChangeSelection: @escaping (Int) -> Void) {
        self.types = types
        self.onChangeSelection = onChangeSelection
    }
    
    @objc func didChangeSelection(sender: UISegmentedControl) {
        onChangeSelection(sender.selectedSegmentIndex)
    }
}
