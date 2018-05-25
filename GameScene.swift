//
//  GameScene.swift
//  WitchOfDewmal
//
//  Created by Bullough, Amber on 5/18/18.
//  Copyright © 2018 CTEC. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let player: UInt32 = 0x1 << 0
    static let grass: UInt32 = 0x1<<1
    static let gem : UInt32 = 0x1 << 2
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Enum for y-position spawn points for grass
    // Ground grass are low and upper platform grass are high
    enum GrassLevel: CGFloat {
        
        case low = 0.0
        case high = 100.0
    }
    let player = Witch(imageNamed: "player.png")
    
    
    var grasses = [SKSpriteNode]()
    var gems = [SKSpriteNode]()
    var grassSize = CGSize.zero
    var grassLevel = GrassLevel.low
    var scrollSpeed: CGFloat = 5.0
    let startingScrollSpeed: CGFloat = 5.0
    var lastUpdateTime: TimeInterval?
    let gravitySpeed: CGFloat = 1.5
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var score: Int = 0
    var highScore: Int = 0
    var lastScoreUpdateTime: TimeInterval = 0.0
    var backgroundSpeed: CGFloat = 80.0
    var deltaTime: TimeInterval = 0
    var lastUpdateTimeInterval: TimeInterval = 0
    
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint.zero
        
        
        //        setUpBackgrounds()
        let background = SKSpriteNode(imageNamed: "background.png")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        addChild(background)
        
        addChild(player)
        
    }
    
    func resetWitch()
    {
        // Sets starting point
        
        let playerX = frame.midX / 2.0
        let playerY = player.frame.height / 2.0 + 64.0
        player.position = CGPoint(x: playerX, y: playerY)
        player.zPosition = 10
        player.minimumY = playerY
    }
    
    func setupLabels() {
        
        // Label that says "score" in the upper left
        
        let scoreTextLabel: SKLabelNode = SKLabelNode(text: "score")
        scoreTextLabel.position = CGPoint(x: 14.0, y: frame.size.height - 20.0)
        scoreTextLabel.horizontalAlignmentMode = .left
        scoreTextLabel.fontName = "Courier-Bold"
        scoreTextLabel.fontSize = 14.0
        scoreTextLabel.zPosition = 20
        addChild(scoreTextLabel)
        
        // Label that shows the player's actual score
        
        let scoreLabel: SKLabelNode = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: 14.0, y: frame.size.height - 40.0)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontName = "Courier-Bold"
        scoreLabel.fontSize = 18.0
        scoreLabel.name = "scoreLabel"
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
        
        // Label that says "high score" in the upper right
        
        let highScoreTextLabel: SKLabelNode = SKLabelNode(text: "high score")
        highScoreTextLabel.position = CGPoint(x: frame.size.width - 14.0, y: frame.size.height - 20.0)
        highScoreTextLabel.horizontalAlignmentMode = .right
        highScoreTextLabel.fontName = "Courier-Bold"
        highScoreTextLabel.fontSize = 14.0
        highScoreTextLabel.zPosition = 20
        addChild(highScoreTextLabel)
        
        // Label that shows the player's actual highest score
        
        let highScoreLabel: SKLabelNode = SKLabelNode(text: "0")
        highScoreLabel.position = CGPoint(x: frame.size.width - 14.0, y: frame.size.height - 40.0)
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.fontName = "Courier-Bold"
        highScoreLabel.fontSize = 18.0
        highScoreLabel.name = "highScoreLabel"
        highScoreLabel.zPosition = 20
        addChild(highScoreLabel)
    }
    
    func updateScoreLabelText() {
        
        if let scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.text = String(format: "%04d", score)
        }
    }
    
    func updateHighScoreLabelText() {
        
        if let highScoreLabel = childNode(withName: "highScoreLabel") as? SKLabelNode {
            highScoreLabel.text = String(format: "%04d", highScore)
        }
    }
    
    func startGame() {
        
        // When a new game is started, reset to starting conditions
        
        resetWitch()
        
        score = 0
        
        scrollSpeed = startingScrollSpeed
        grassLevel = .low
        lastUpdateTime = nil
        
        for grass in grasses {
            grass.removeFromParent()
        }
        
        grasses.removeAll(keepingCapacity: true)
        
        for gem in gems {
            removeGem(gem)
        }
    }
    
    func gameOver() {
        
        // When the game ends, see if the player got a new high score
        
        if score > highScore {
            highScore = score
            
            updateHighScoreLabelText()
        }
        
        startGame()
    }
    
    func spawnGrass(atPosition position: CGPoint) -> SKSpriteNode {
        
        // Create a grass sprite and add it to the scene
        let grass = SKSpriteNode(imageNamed: "ground")
        grass.position = position
        grass.zPosition = 8
        addChild(grass)
        
        // Update our grassSize with the real grass size
        grassSize = grass.size
        
        // Add the new grass to the array of grass
        grasses.append(grass)
        
        // Set up the grass's physics body
        let center = grass.centerRect.origin
        grass.physicsBody = SKPhysicsBody(rectangleOf: grass.size, center: center)
        grass.physicsBody?.affectedByGravity = false
        
        grass.physicsBody?.categoryBitMask = PhysicsCategory.grass
        grass.physicsBody?.collisionBitMask = 0
        
        // Return this new grass to the caller
        return grass
    }
    
    func spawnGem(atPosition position: CGPoint) {
        
        // Create a gem sprite and add it to the scene
        let gem = SKSpriteNode(imageNamed: "gem")
        gem.position = position
        gem.zPosition = 9
        addChild(gem)
        
        gem.physicsBody = SKPhysicsBody(rectangleOf: gem.size, center: gem.centerRect.origin)
        gem.physicsBody?.categoryBitMask = PhysicsCategory.gem
        gem.physicsBody?.affectedByGravity = false
        
        // Add the new gem to the array of gems
        gems.append(gem)
    }
    
    func removeGem(_ gem: SKSpriteNode) {
        
        gem.removeFromParent()
        
        if let gemIndex = gems.index(of: gem) {
            gems.remove(at: gemIndex)
        }
    }
    
    func updateGrass(withScrollAmount currentScrollAmount: CGFloat)
    {
        var farthestRightGrassX: CGFloat = 0.0
        
        for grass in grasses
        {
            
            let newX = grass.position.x - currentScrollAmount
            
            if newX < -grassSize.width
            {
                grass.removeFromParent()
                
                if let grassIndex = grasses.index(of: grass)
                {
                    grasses.remove(at: grassIndex)
                }
            }
            else
            {
                grass.position = CGPoint(x: newX, y: grass.position.y)
                if grass.position.x > farthestRightGrassX
                {
                    farthestRightGrassX = grass.position.x
                }
            }
            if grass.position.x > farthestRightGrassX
            {
                farthestRightGrassX = grass.position.x
            }
            
        }
        
        // A while loop to ensure our screen is always full of grass
        while farthestRightGrassX < frame.width {
            
            var grassX = farthestRightGrassX + grassSize.width + 1.0
            let grassY = grassSize.height / 2.0
            
            // Every now and then, leave a gap the player must jump over
            let randomNumber = arc4random_uniform(99)
            
            if randomNumber < 5 {
                
                // There is a 5 percent chance that we will
                // leave a gap between grass
                let gap = 20.0 * scrollSpeed
                grassX += gap
            }
            
            // Spawn a new grass and update the rightmost grass
            let newGrass = spawnGrass(atPosition: CGPoint(x: grassX, y: grassY))
            farthestRightGrassX = newGrass.position.x
        }
        
        func updateGems(withScrollAmount currentScrollAmount: CGFloat) {
            
            for gem in gems {
                
                // Update each gem's position
                let thisGemX = gem.position.x - currentScrollAmount
                gem.position = CGPoint(x: thisGemX, y: gem.position.y)
                
                // Remove any gems that have moved offscreen
                if gem.position.x < 0.0 {
                    
                    removeGem(gem)
                }
            }
        }
        
        func updatePlayer() {
            
            // Determine if the player is currently on the ground
            if let velocityY = player.physicsBody?.velocity.dy {
                
                if velocityY < -100.0 || velocityY > 100.0 {
                    player.isOnGround = false
                }
            }
            
            // Check if the game should end
            let isOffScreen = player.position.y < 0.0 || player.position.x < 0.0
            
            let maxRotation = CGFloat(GLKMathDegreesToRadians(85.0))
            let isTippedOver = player.zRotation > maxRotation || player.zRotation < -maxRotation
            
            if isOffScreen || isTippedOver {
                gameOver()
            }
        }
        
        func updateScore(withCurrentTime currentTime: TimeInterval) {
            
            // The player's score increases the longer they survive
            // Only update score every 1 second
            
            let elapsedTime = currentTime - lastScoreUpdateTime
            
            if elapsedTime > 1.0 {
                
                // Increase the score
                score += Int(scrollSpeed)
                
                // Reset the lastScoreUpdateTime to the current time
                lastScoreUpdateTime = currentTime
                
                updateScoreLabelText()
            }
        }
        func update(_ currentTime: TimeInterval) {
            
            // Slowly increase the scrollSpeed as the game progresses
            scrollSpeed += 0.01
            
            // Determine the elapsed time since the last update call
            var elapsedTime: TimeInterval = 0.0
            
            if let lastTimeStamp = lastUpdateTime {
                elapsedTime = currentTime - lastTimeStamp
            }
            
            lastUpdateTime = currentTime
            
            let expectedElapsedTime: TimeInterval = 1.0 / 60.0
            
            // Here we calculate how far everything should move in this update
            let scrollAdjustment = CGFloat(elapsedTime / expectedElapsedTime)
            let currentScrollAmount = scrollSpeed * scrollAdjustment
            
            updateGrass(withScrollAmount: currentScrollAmount)
            updatePlayer()
            updateGems(withScrollAmount: currentScrollAmount)
            updateScore(withCurrentTime: currentTime)
        }
        
        func handleTap(tapGesture: UITapGestureRecognizer) {
            
            // Make the player jump if player taps while she is on the ground
            if player.isOnGround {
                
                player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 260.0))
            }
        }
        
        
        // MARK:- SKPhysicsContactDelegate Methods
        
        func didBegin(_ contact: SKPhysicsContact) {
            
            // Check if the contact is between the Player and a grass
            if contact.bodyA.categoryBitMask == PhysicsCategory.player && contact.bodyB.categoryBitMask == PhysicsCategory.grass {
                
                player.isOnGround = true
            }
            else if contact.bodyA.categoryBitMask == PhysicsCategory.player && contact.bodyB.categoryBitMask == PhysicsCategory.gem {
                
                // Player touched a gem, so remove it
                if let gem = contact.bodyB.node as? SKSpriteNode {
                    
                    removeGem(gem)
                    
                    // Give the player 50 points for getting a gem
                    score += 50
                    updateScoreLabelText()
                }
            }
        }
        
        
        
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
//
//                }
//
//                for i in 0..<1 {
//                    let ground = SKSpriteNode(imageNamed: "ground.png")
//                    ground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//                    ground.size = CGSize(width: self.size.width, height: ground.size.height)
//                    ground.position = CGPoint(x: CGFloat(i) * size.width, y: 0)
//                    ground.zPosition = 1 //Z is how close to screen not up and down
//                    ground.name = "ground"
//                    self.addChild(ground)
//
//                }
          }
                }
//
//        //
    }
}

