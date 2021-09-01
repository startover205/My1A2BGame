//
//  Animate.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/9/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import Foundation

public typealias Animate = ((_ duration: TimeInterval,
                             _ animations: @escaping () -> Void,
                             _ completion: ((Bool) -> Void)?) -> Void)
