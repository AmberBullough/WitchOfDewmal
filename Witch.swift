//
//  Witch.swift
//  WitchOfDewmal
//
//  Created by Bullough, Amber on 5/25/18.
//  Copyright © 2018 CTEC. All rights reserved.
//


import SpriteKit

class Witch: SKSpriteNode {
    
    var velocity = CGPoint.zero
    var minimumY: CGFloat = 0.0
    var jumpSpeed: CGFloat = 20.0
    var isOnGround = true
    
    func setupPhysicsBody() {
        
        if let witchTexture = texture {
            
            physicsBody = SKPhysicsBody(texture: witchTexture, size: size)
            physicsBody?.isDynamic = true
            physicsBody?.density = 6.0
            physicsBody?.allowsRotation = false
            physicsBody?.angularDamping = 1.0
            
            physicsBody?.categoryBitMask = PhysicsCategory.player
            physicsBody?.collisionBitMask = PhysicsCategory.grass
            physicsBody?.contactTestBitMask = PhysicsCategory.grass | PhysicsCategory.gem
        }
    }
}

