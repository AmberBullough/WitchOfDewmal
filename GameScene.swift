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
    static let hay: UInt32 = 0x1<<1
    static let gem : UInt32 = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Enum for y-position spawn points for grasses
    // Ground grasses are low and upper platform grasses are high
    enum GrassLevel: CGFloat {
        
        case low = 0.0
        case high = 55.0
    }
    
    enum HayLevel: CGFloat{
        case low = 0.0
        case high = 20.0
    }
    
    // This enum defines the states the game may be in
    enum GameState {
        case notRunning
        case running
    }
    
    // MARK:- Class Properties
    
    // An array that holds all the current ground grasses
    var grasses = [SKSpriteNode]()
    
    var hays = [SKSpriteNode]()
    
    // An array that holds all the current gems
    var gems = [SKSpriteNode]()
    
    // The size of the ground grass graphics used
    var grassSize = CGSize.zero
    
    var haySize = CGSize.zero
    
    // The current grass level determines the y-position of new grasses
    var grassLevel = GrassLevel.low
    var hayLevel = HayLevel.low
    // The current game state is tracked
    var gameState = GameState.notRunning
    
    // Setting for how fast the game is scrolling to the right
    // This may increase as the user progresses in the game
    var scrollSpeed: CGFloat = 5.0
    let startingScrollSpeed: CGFloat = 5.0
    
    // A constant for gravity, or how fast objects will fall to earth
    let gravitySpeed: CGFloat = 1.5
    
    // Properties for score-tracking
    var score: Int = 0
    var highScore: Int = 0
    var lastScoreUpdateTime: TimeInterval = 0.0
    
    // The timestamp of the last update method call
    var lastUpdateTime: TimeInterval?
    
    // The hero of the game, the player, is created here
//   let player = Witch(imageNamed: "player")
    lazy var player = Witch()
    
//
    private var witch = SKSpriteNode()
    private var witchRunningFrames: [SKTexture] = []
    
    // MARK:- Setup and Lifecycle Methods
    
    
    override func didMove(to view: SKView) {
        
        //Affects gravity on you
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.5)
        physicsWorld.contactDelegate = self
        
        anchorPoint = CGPoint.zero
        
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        addChild(background)
        
        setupLabels()
        
        // Set up the player and add her to the scene
        player.setupPhysicsBody()
        addChild(player)
        buildPlayer()
        animatePlayer()
        
        // Add a tap gesture recognizer to know when the user tapped the screen
        let tapMethod = #selector(GameScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view.addGestureRecognizer(tapGesture)
        
        // Add a menu overlay with "Tap to play" text
        let menuBackgroundColor = UIColor.black.withAlphaComponent(0.4)
        let menuLayer = MenuLayer(color: menuBackgroundColor, size: frame.size)
        menuLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        menuLayer.position = CGPoint(x: 0.0, y: 0.0)
        menuLayer.zPosition = 30
        menuLayer.name = "menuLayer"
        menuLayer.display(message: "Tap to play", score: nil)
        addChild(menuLayer)
    }
    func buildPlayer() {
        let playerAnimatedAtlas = SKTextureAtlas(named: "player")
        var walkFrames: [SKTexture] = []
        
        let numImages = playerAnimatedAtlas.textureNames.count
        for i in 0...numImages {
            let playerTextureName = "player\(i)"
            walkFrames.append(playerAnimatedAtlas.textureNamed(playerTextureName))
        }
        witchRunningFrames = walkFrames
        
        let firstFrameTexture = witchRunningFrames[0]
        player = Witch()
        player.texture = firstFrameTexture
        
        let playerX = frame.midX / 2.0
        let playerY = player.frame.height / 2.0 + 64.0
        player.position = CGPoint(x: playerX, y: playerY)
        player.zPosition = 10
        player.minimumY = playerY
        addChild(player)
    }
    
    func animatePlayer() {
       player.run(SKAction.repeatForever(
            SKAction.animate(with: witchRunningFrames,
                             timePerFrame: 0.1,
                             resize: false,
                             restore: true)),
                 withKey:"runningInPlaceWitch")
    }
    
    func resetPlayer() {
        
        // Set the player's starting position, zPosition, and minimumY
        let playerX = frame.midX / 2.0
        let playerY = player.frame.height / 2.0 + 64.0
        player.position = CGPoint(x: playerX, y: playerY)
        player.zPosition = 10
        player.minimumY = playerY
        
        player.zRotation = 0.0
        player.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        player.physicsBody?.angularVelocity = 0.0
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
        
        gameState = .running
        
        resetPlayer()
        
        score = 0
        
        scrollSpeed = startingScrollSpeed
        grassLevel = .low
        hayLevel = .low
        lastUpdateTime = nil
        
        for grass in grasses {
            grass.removeFromParent()
        }
        
        for hay in hays {
            hay.removeFromParent()
        }
        
        grasses.removeAll(keepingCapacity: true)
        hays.removeAll(keepingCapacity: true)
        
        for gem in gems {
            removeGem(gem)
        }
    }
    
    func gameOver() {
        
        // When the game ends, see if the player got a new high score
        
        gameState = .notRunning
        
        if score > highScore {
            highScore = score
            
            updateHighScoreLabelText()
        }
        
        // Show the "Game Over!" menu overlay
        let menuBackgroundColor = UIColor.black.withAlphaComponent(0.4)
        let menuLayer = MenuLayer(color: menuBackgroundColor, size: frame.size)
        menuLayer.anchorPoint = CGPoint.zero
        menuLayer.position = CGPoint.zero
        menuLayer.zPosition = 30
        menuLayer.name = "menuLayer"
        menuLayer.display(message: "Game Over!", score: score)
        addChild(menuLayer)
    }
    
    
    // MARK:- Spawn and Remove Methods
    
    func spawnGrass(atPosition position: CGPoint) -> SKSpriteNode {
        
        // Create a grass sprite and add it to the scene
        let grass = SKSpriteNode(imageNamed: "ground")
        grass.position = position
        grass.zPosition = 8
        addChild(grass)
        
        // Update our grassSize with the real grass size
        grassSize = grass.size
        
        // Add the new grass to the array of grasses
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
    
    func spawnHay(atPosition position: CGPoint) -> SKSpriteNode {
        
        // Create a hay sprite and add it to the scene
        let hay = SKSpriteNode(imageNamed: "hay")
        hay.position = position
        hay.zPosition = 8
        addChild(hay)
        
        // Update our haySize with the real hay size
        haySize = hay.size
        
        // Add the new hay to the array of hays
        hays.append(hay)
        
        // Set up the hay's physics body
        let center = hay.centerRect.origin
        hay.physicsBody = SKPhysicsBody(rectangleOf: hay.size, center: center)
        hay.physicsBody?.affectedByGravity = false
        
        hay.physicsBody?.categoryBitMask = PhysicsCategory.hay
        hay.physicsBody?.collisionBitMask = 0
        
        // Return this new hay to the caller
        return hay
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
    
    
    // MARK:- Update Methods
    
    func updateGrasses(withScrollAmount currentScrollAmount: CGFloat) {
        
        // Keep track of the greatest x-position of all the current grasses
        var farthestRightGrassX: CGFloat = 0.0
        
        for grass in grasses {
            
            let newX = grass.position.x - currentScrollAmount
            
            // If a grass has moved too far left (off the screen), remove it
            if newX < -grassSize.width {
                
                grass.removeFromParent()
                
                if let grassIndex = grasses.index(of: grass) {
                    grasses.remove(at: grassIndex)
                }
                
            } else {
                
                // For a grass that is still onscreen, update its position
                grass.position = CGPoint(x: newX, y: grass.position.y)
                
                // Update our farthest-right position tracker
                if grass.position.x > farthestRightGrassX {
                    farthestRightGrassX = grass.position.x
                }
            }
        }
        
        // A while loop to ensure our screen is always full of grasses
        while farthestRightGrassX < frame.width {
            
            var grassX = farthestRightGrassX + grassSize.width + 1.0
            let grassY = (grassSize.height / 2.0) + grassLevel.rawValue
            
            // Every now and then, leave a gap the player must jump over
            let randomNumber = arc4random_uniform(99)
            
            if randomNumber < 2 && score > 10 {
                
                // There is a 2 percent chance that we will leave a gap between
                // grasses after the player has reached a score of 10
                let gap = 30.0 * scrollSpeed
                grassX += gap
                
                // At each gap, add a gem
                let randomGemYAmount = CGFloat(arc4random_uniform(150))
                let newGemY = grassY + player.size.height + randomGemYAmount
                let newGemX = grassX - gap / 2.0
                
                spawnGem(atPosition: CGPoint(x: newGemX, y: newGemY))
            }
            else if randomNumber < 4 && score > 20 {
                
                // There is a 2 percent chance that the grass Y level will change
                // after the player has reached a score of 20
                if grassLevel == .high {
                    grassLevel = .low
                }
                else if grassLevel == .low {
                    grassLevel = .high
                }
            }
            
            // Spawn a new grass and update the rightmost grass
            let newGrass = spawnGrass(atPosition: CGPoint(x: grassX, y: grassY))
            farthestRightGrassX = newGrass.position.x
        }
        
        while farthestRightGrassX < frame.width {
            
            var hayX = farthestRightGrassX + haySize.width + 1.0
            let hayY = (haySize.height / 2.0) + hayLevel.rawValue
            
            // Every now and then, leave a gap the player must jump over
            let randomNumber = arc4random_uniform(99)
            
            if randomNumber < 2 && score > 10 {
                
                // There is a 2 percent chance that we will leave a gap between
                // hays after the player has reached a score of 10
                let gap = 20.0 * scrollSpeed
                hayX += gap
                
                // At each gap, add a gem
                let randomGemYAmount = CGFloat(arc4random_uniform(150))
                let newGemY = hayY + player.size.height + randomGemYAmount
                let newGemX = hayX - gap / 2.0
                
                spawnGem(atPosition: CGPoint(x: newGemX, y: newGemY))
            }
            else if randomNumber < 4 && score > 20 {
                
                // There is a 2 percent chance that the hay Y level will change
                // after the player has reached a score of 20
                if hayLevel == .high {
                    hayLevel = .low
                }
                else if hayLevel == .low {
                    hayLevel = .high
                }
            }
            
            // Spawn a new hay and update the rightmost hay
            let newHay = spawnHay(atPosition: CGPoint(x: hayX, y: hayY))
            farthestRightGrassX = newHay.position.x
        }
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
    
    
    // MARK:- Main Game Loop Method
    
    override func update(_ currentTime: TimeInterval) {
        
        if gameState != .running {
            return
        }
        
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
        
        updateGrasses(withScrollAmount: currentScrollAmount)
        updatePlayer()
        updateGems(withScrollAmount: currentScrollAmount)
        updateScore(withCurrentTime: currentTime)
    }
    
    
    // MARK:- Touch Handling Methods
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        
        if gameState == .running {
            
            // Make the player jump if player taps while she is on the ground
            if player.isOnGround {
                
                player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 260.0))
                
                run(SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false))
            }
        }
        else {
            
            // If the game is not running, tapping starts a new game
            if let menuLayer: SKSpriteNode = childNode(withName: "menuLayer") as? SKSpriteNode {
                
                menuLayer.removeFromParent()
            }
            
            startGame()
        }
    }
    
    
    // MARK:- SKPhysicsContactDelegate Methods
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Check if the contact is between the player and a grass
        if contact.bodyA.categoryBitMask == PhysicsCategory.player && contact.bodyB.categoryBitMask == PhysicsCategory.grass {
            
            if let velocityY = player.physicsBody?.velocity.dy {
                
                if !player.isOnGround && velocityY < 100.0 {
                    
                    player.createSparks()
                }
            }
            
            player.isOnGround = true
        }
        else if contact.bodyA.categoryBitMask == PhysicsCategory.player && contact.bodyB.categoryBitMask == PhysicsCategory.gem {
            
            // Player touched a gem, so remove it
            if let gem = contact.bodyB.node as? SKSpriteNode {
                
                removeGem(gem)
                
                // Give the player 50 points for getting a gem
                score += 50
                updateScoreLabelText()
                
                run(SKAction.playSoundFileNamed("gem.wav", waitForCompletion: false))
            }
        }
        
    }
}



