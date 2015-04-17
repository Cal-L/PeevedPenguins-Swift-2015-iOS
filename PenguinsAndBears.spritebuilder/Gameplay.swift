//
//  Gameplay.swift
//  PenguinsAndBears
//
//  Created by Cal on 4/16/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Gameplay: CCNode, CCPhysicsCollisionDelegate {
    
    var _physicsNode : CCPhysicsNode!
    var _catapultArm : CCNode!
    var _levelNode : CCNode!
    var _contentNode : CCNode!
    var _pullbackNode : CCNode!
    var _mouseJointNode : CCNode!
    var _mouseJoint : CCPhysicsJoint!
    var _currentPenguin : CCNode!
    var _penguinCatapultJoint : CCPhysicsJoint!
    var MIN_SPEED : CGFloat = 10
    var _followPenguin : CCAction!
    var launched = false
    
    func didLoadFromCCB() {
        self.userInteractionEnabled = true
        var level = CCBReader.load("Levels/Level1")
        _levelNode.addChild(level)
        //_physicsNode.debugDraw = true
        _pullbackNode.physicsBody.collisionMask = []
        _mouseJointNode.physicsBody.collisionMask = []
        _physicsNode.collisionDelegate = self
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        var touchLocation = touch.locationInNode(_contentNode)
        
        if (CGRectContainsPoint(_catapultArm.boundingBox(), touchLocation)) {
            _currentPenguin = CCBReader.load("Penguin")
            var penguinPosition = _catapultArm.convertToWorldSpace(ccp(34,138))
            _currentPenguin.position = _physicsNode.convertToNodeSpace(penguinPosition)
            _physicsNode.addChild(_currentPenguin)
            _currentPenguin.physicsBody.allowsRotation = false
            _penguinCatapultJoint = CCPhysicsJoint.connectedPivotJointWithBodyA(_currentPenguin.physicsBody, bodyB: _catapultArm.physicsBody, anchorA: _currentPenguin.anchorPointInPoints)
            
            _mouseJointNode.position = touchLocation
            _mouseJoint = CCPhysicsJoint.connectedSpringJointWithBodyA(_mouseJointNode.physicsBody, bodyB: _catapultArm.physicsBody, anchorA: ccp(0,0), anchorB: ccp(34,138), restLength: 0, stiffness: 3000, damping: 150)
        }
        
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        var touchLocation = touch.locationInNode(_contentNode)
        _mouseJointNode.position = touchLocation
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        self.releaseCatapult()
    }
    
    override func touchCancelled(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        self.releaseCatapult()
    }
    
    func releaseCatapult() {
        if (_mouseJoint != nil) {
            _mouseJoint.invalidate()
            _mouseJoint = nil
            _penguinCatapultJoint.invalidate()
            _penguinCatapultJoint = nil
            _currentPenguin.physicsBody.allowsRotation = true
            _followPenguin = CCActionFollow(target: _currentPenguin, worldBoundary: self.boundingBox())
            _contentNode.runAction(_followPenguin)
            launched = true
        }
    }
    
    //Collisions
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, seal nodeA: CCNode!, wildcard nodeB: CCNode!) {
        if (nodeA != nil) {
            var force = pair.totalKineticEnergy
            if (force > 5000) {
                sealRemoved(nodeA)
            }
        }
        
    }
    
    func sealRemoved(seal : CCNode) {
        var explosion : CCParticleSystem = CCBReader.load("SealExplosion") as CCParticleSystem
        explosion.autoRemoveOnFinish = true
        explosion.position = seal.position
        seal.parent.addChild(explosion)
        seal.removeFromParent()
    }
    
    func launchPenguin() {
        var penguin = CCBReader.load("Penguin")
        penguin.position = ccpAdd(_catapultArm.position, ccp(50,150))
        _physicsNode.addChild(penguin)
        
        let launchDirection = ccp(1,0)
        let force = ccpMult(launchDirection, 8000)
        penguin.physicsBody.applyForce(force)
        
        self.position = ccp(0,0)
        var follow = CCActionFollow(target: penguin, worldBoundary: self.boundingBox())
        _contentNode.runAction(follow)
    }
    
    func retry() {
        var gameplayScene = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().replaceScene(gameplayScene)
    }
    
    func nextAttempt() {
        _currentPenguin = nil
        _contentNode.stopAction(_followPenguin)
        var sec : CCTime = 1
        var actionMoveTo = CCActionMoveTo.actionWithDuration(sec, position: ccp(0,0)) as CCActionMoveTo
        _contentNode.runAction(actionMoveTo)
    }
    
    override func update(delta: CCTime) {
        if (launched == true) {
            if (_currentPenguin.position.x > self.boundingBox().size.width) {
                self.nextAttempt()
                launched = false
            } else if (_currentPenguin.position.x < self.boundingBox().origin.x) {
                self.nextAttempt()
                launched = false
            } else if (ccpLength(_currentPenguin.physicsBody.velocity) < MIN_SPEED) {
                self.nextAttempt()
                launched = false
            }
        }
    }
    
}
