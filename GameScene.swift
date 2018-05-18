//
//  GameScene.swift
//  WitchOfDewmal
//
//  Created by Bullough, Amber on 5/18/18.
//  Copyright © 2018 CTEC. All rights reserved.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene {
    
       var ground = SKSpriteNode()
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var backgroundSpeed: CGFloat = 80.0 // speed may vary as you like
    var deltaTime: TimeInterval = 0
    var lastUpdateTimeInterval: TimeInterval = 0
    
    func setUpBackgrounds() {
        //add background
        
        for i in 0..<3 {
            // add backgrounds, my images were namely, bg-0.png, bg-1.png, bg-2.png
            
            let background = SKSpriteNode(imageNamed: "background.png")
            background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            background.position = CGPoint(x: CGFloat(i) * size.width, y: 0.0)
            background.size = self.size
            background.zPosition = -10
            background.name = "background"
            self.addChild(background)
            
        }
        
        for i in 0..<3 {
            let ground = SKSpriteNode(imageNamed: "ground.png")
            ground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            ground.size = CGSize(width: self.size.width, height: ground.size.height)
            ground.position = CGPoint(x: CGFloat(i) * size.width, y: 0)
            ground.zPosition = 1
            ground.name = "ground"
            self.addChild(ground)
            
        }
    }
    override func didMove(to view: SKView) {
        
        setUpBackgrounds()
            
        }
        
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTimeInterval == 0 {
            lastUpdateTimeInterval = currentTime
        }
        
        deltaTime = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        
        //MARK:- Last step:- add these methods here
       // updateBackground()
       // updateGroundMovement()
    }
  
}

