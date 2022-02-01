//
//  AsyncAfter.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2022/2/2.
//  Copyright © 2022 Ming-Ta Yang. All rights reserved.
//

import Foundation

public typealias AsyncAfter = (TimeInterval, @escaping () -> Void) -> Void
