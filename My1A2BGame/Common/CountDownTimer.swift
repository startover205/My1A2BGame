//
//  CountDownTimer.swift
//  EasyTimer
//
//  Created by Ming-Ta Yang on 2019/2/15.
//  Copyright © 2019年 Sam's App Lab. All rights reserved.
//

import Foundation

/// A countdown timer uses seconds as minimum timeinterval
class CountDownTimer {
    private var timer: Timer?
    private var totalSeconds: Int
    private var tickHandler: DoneHandler?
    private var completeHandler: DoneHandler?
    private var doRepeat: Bool
    private var isPause = false
    
    private(set) var leftSeconds: Int = 0

    typealias DoneHandler = () -> ()

    init(timeInterval: Int, tickHandler: DoneHandler?, completeHandler: DoneHandler?, doRepeat: Bool) {
        self.totalSeconds = timeInterval
        self.tickHandler = tickHandler
        self.completeHandler = completeHandler
        self.doRepeat = doRepeat
        
        timer?.invalidate()
        leftSeconds = totalSeconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(uponTick), userInfo: nil, repeats: true)
    }
    
    func restart(){
        leftSeconds = totalSeconds
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(uponTick), userInfo: nil, repeats: true)
    }
    
    func pause(){
        timer?.invalidate()
        timer = nil
    }

    func doContinue(){
         timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(uponTick), userInfo: nil, repeats: true)
    }
    
    func stop(){
        timer?.invalidate()
        timer = nil
    }
    
    func accelerate(with seconds: Int){
        if leftSeconds > seconds{
            self.leftSeconds -= seconds
        } else {
            self.stop()
        }
    }
    
    @objc
    func uponTick(){
        leftSeconds -= 1
        
        if leftSeconds <= 0{
            
            if let completeHandler = completeHandler {
                completeHandler()
            }
            
            leftSeconds = totalSeconds
            
            if !doRepeat {
                self.stop()
            }
            
        } else if let tickHandler = tickHandler {
            tickHandler()
        }
        
        
    }

}
