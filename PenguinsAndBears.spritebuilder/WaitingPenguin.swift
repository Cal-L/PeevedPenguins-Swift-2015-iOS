//
//  WaitingPenguin.swift
//  PenguinsAndBears
//
//  Created by Cal on 4/16/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class WaitingPenguin: CCSprite {
    
    func didLoadFromCCB() {
        var delay : Double = Double(arc4random() % 2000) / 1000
        self.scheduleOnce("startBlinkAndJump", delay: delay)
    }
    
    func startBlinkAndJump() {
        
    }
    
}
