//
//  Global.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/3/28.
//  Copyright © 2019年 Ming-Ta Yang. All rights reserved.
//

import os.log

func print(_ text: String, _ type: OSLogType) {
    #if DEBUG
    os_log("%@", type: type, text) // 需使用 %@ 轉換 String 為 StaticString
    #endif
}

