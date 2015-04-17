//
//  Seal.swift
//  PenguinsAndBears
//
//  Created by Cal on 4/16/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Seal: CCSprite {
    
    func didLoadFromCCB() {
        self.physicsBody.collisionType = "seal"
    }
    
}