//
//  GamePlayScene.swift
//  SwiftOrb
//
//  Created by Jonathan Deehan on 09/05/2016.
//  Copyright © 2016 Mahogany Games. All rights reserved.
//

import SpriteKit
import GameplayKit

struct Settings {
    struct Metrics {
        static let projectileRadius = CGFloat(10)
        static let projectileRestPosition = CGPoint(x: 187.5, y: 100)
        static let projectileTouchThreshold = CGFloat(10)
        static let projectileSnapLimit = CGFloat(10)
        static let forceMultiplier = CGFloat(0.5)
        static let rLimit = CGFloat(50)
    }
    struct Game {
        static let gravity = CGVector(dx: 0,dy: 0)
    }
}

class GamePlayScene: SKScene, SKPhysicsContactDelegate {
    
    // ====== Nodes ======
    // Orb
    var orb = SKShapeNode()
    var staticOrb = SKSpriteNode()
    var trail = SKEmitterNode()
    // Surrounding Body
    var ground = SKNode()
    // Parent Nodes
    var movingObjects = SKNode()
    var staticObjects = SKNode()
    var targetObjects = SKNode()
    var barrierObjects = SKNode()
    // Target
    var target = SKShapeNode()
    var explosionEmitterNode = SKEmitterNode()
    // Barrier
    var barrier1 = SKShapeNode()
    var barrier2 = SKShapeNode()
    var barrier3 = SKShapeNode()
    // Label Nodes
    var scoreLabel = SKLabelNode()
    var timerLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var startGameBtn = SKLabelNode()
    // ====== CategoryBitMask ======
    let surfaceGroup  : UInt32 = 0x1 << 0
    let orbGroup : UInt32 = 0x1 << 1
    let targetGroup : UInt32 = 0x1 << 2
    let barriersGroup : UInt32 = 0x1 << 3
    // ====== States ======
    // Game over state
    var gameOver = false
    // Time
    var timer = NSTimer()
    var time = 20
    var timeRepeat:Bool = true
    // Pause State
    var pause = false
    var pauseLoop = false
    // ====== Score ======
    var score = 0
    // Orb Position
    var projectileIsDragged = false
    var touchCurrentPoint: CGPoint!
    var touchStartingPoint :CGPoint!
    
    // Actions
//    var moveLeft = SKAction()
//    var moveRight = SKAction()
//    var moveBarriersForever_1 = SKAction()
//    var moveBarriersForever_2 = SKAction()
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        // Gravity
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = Settings.Game.gravity
        self.physicsWorld.speed = 1.5
        
        // Parent Nodes
        self.addChild(movingObjects)
        self.addChild(staticObjects)
        self.addChild(targetObjects)
        self.addChild(barrierObjects)
        
        // Ground
        ground.position = CGPointMake(0,0.1)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width*3, 1))
        ground.physicsBody!.dynamic = false
        ground.physicsBody?.categoryBitMask = surfaceGroup
        self.addChild(ground)
        // Borders
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        // Background
        self.backgroundColor = UIColor.darkGrayColor()
        
        // Score
        scoreLabel.fontName = "Courier-Bold"
        scoreLabel.fontColor = UIColor.cyanColor()
        scoreLabel.fontSize = 60
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 70)
        scoreLabel.zPosition = 30
        self.addChild(scoreLabel)
        
        // Timer
        timerLabel.fontName = "Courier-Bold"
        timerLabel.fontColor = UIColor.cyanColor()
        timerLabel.fontSize = 40
        timerLabel.text = "20"
        timerLabel.horizontalAlignmentMode = .Right
        timerLabel.position = CGPoint(x:self.frame.size.width, y:self.frame.size.height-30)
        timerLabel.zPosition = 30
        self.addChild(timerLabel)
        
        // Orb
        orb.zPosition = 15
        orb.fillColor = UIColor.redColor()
        orb.physicsBody = SKPhysicsBody(circleOfRadius: Settings.Metrics.projectileRadius)
        orb.physicsBody!.affectedByGravity = true
        orb.physicsBody?.allowsRotation = false
        orb.physicsBody?.categoryBitMask = orbGroup
        orb.physicsBody?.collisionBitMask = targetGroup | barriersGroup
        orb.physicsBody?.contactTestBitMask = surfaceGroup
        orb.strokeColor = UIColor.blueColor()
        
        // Barrier Actions
        var moveLeft = SKAction.moveBy(CGVector(dx: 70,dy: 0), duration: 1)
        var moveRight = SKAction.moveBy(CGVector(dx: -70,dy: 0), duration: 1)
        var moveBarriersForever_1 = SKAction.repeatActionForever(SKAction.sequence([moveLeft, moveLeft.reversedAction()]))
        var moveBarriersForever_2 = SKAction.repeatActionForever(SKAction.sequence([moveRight, moveRight.reversedAction()]))
        
        // Barriers
        barrier1 = SKShapeNode(circleOfRadius: Settings.Metrics.projectileRadius*2)
        barrier1.physicsBody = SKPhysicsBody(circleOfRadius: Settings.Metrics.projectileRadius*2)
        barrier1.physicsBody!.affectedByGravity = false
        barrier1.physicsBody?.allowsRotation = false
        barrier1.physicsBody?.categoryBitMask = barriersGroup
        barrier1.physicsBody?.collisionBitMask = barriersGroup
        barrier1.physicsBody?.contactTestBitMask = orbGroup
        barrier1.strokeColor = SKColor.blackColor()
        barrier1.fillColor = UIColor.cyanColor()
        barrier1.zPosition = 21
        barrier1.glowWidth = 1.0
        barrier1.runAction(moveBarriersForever_1)
        
        barrier2 = SKShapeNode(circleOfRadius: Settings.Metrics.projectileRadius*2)
        barrier2.physicsBody = SKPhysicsBody(circleOfRadius: Settings.Metrics.projectileRadius*2)
        barrier2.physicsBody!.affectedByGravity = false
        barrier2.physicsBody?.allowsRotation = false
        barrier2.physicsBody?.categoryBitMask = barriersGroup
        barrier2.physicsBody?.collisionBitMask = barriersGroup
        barrier2.physicsBody?.contactTestBitMask = orbGroup
        barrier2.strokeColor = SKColor.blackColor()
        barrier2.fillColor = UIColor.cyanColor()
        barrier2.zPosition = 21
        barrier2.glowWidth = 1.0
        barrier2.runAction(moveBarriersForever_2)
        
        barrier3 = SKShapeNode(circleOfRadius: Settings.Metrics.projectileRadius*2)
        barrier3.physicsBody = SKPhysicsBody(circleOfRadius: Settings.Metrics.projectileRadius*2)
        barrier3.physicsBody!.affectedByGravity = false
        barrier3.physicsBody?.allowsRotation = false
        barrier3.physicsBody?.categoryBitMask = barriersGroup
        barrier3.physicsBody?.collisionBitMask = barriersGroup
        barrier3.physicsBody?.contactTestBitMask = orbGroup
        barrier3.strokeColor = SKColor.blackColor()
        barrier3.fillColor = UIColor.cyanColor()
        barrier3.zPosition = 21
        barrier3.glowWidth = 1.0
        barrier3.runAction(moveBarriersForever_1)
        
        // Static Orb
        let staticOrbTexture = SKTexture(imageNamed: "redball_20.png")
        staticOrb = SKSpriteNode(texture: staticOrbTexture)
        staticOrb.position = CGPoint(x: 187.5, y: 100)
        staticOrb.zPosition = 14
        
        startGame()
    }
    
    func setupThrowArea() {
        // OrbPath
        let projectilePath = UIBezierPath(
            arcCenter: CGPoint.zero,
            radius: Settings.Metrics.projectileRadius,
            startAngle: 0,
            endAngle: CGFloat(M_PI * 2),
            clockwise: true
        )
        // Orb Configuration
        orb.position = CGPoint(x: 187.5, y: 100)
        orb.path = projectilePath.CGPath
        movingObjects.addChild(orb)
        
        // Particle Trail
        trail = SKEmitterNode(fileNamed: "OrbTrail")!
        trail.particlePosition = orb.position
        movingObjects.addChild(trail)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if(!gameOver){
            
            if (contact.bodyA.categoryBitMask == surfaceGroup || contact.bodyB.categoryBitMask == surfaceGroup){
                movingObjects.removeAllChildren()
                let myFunction = SKAction.runBlock({()in self.setupThrowArea()})
                self.runAction(myFunction)
            }
            
            if (contact.bodyA.categoryBitMask == targetGroup || contact.bodyB.categoryBitMask == targetGroup){
                explosionEmitterNode.removeFromParent()
                explosionEmitterNode = SKEmitterNode(fileNamed:"Explosion")!
                explosionEmitterNode.position = orb.position
                self.addChild(explosionEmitterNode)
                targetObjects.removeAllChildren() // target.removeFromParent() previously
                movingObjects.removeAllChildren()
                let myFunction = SKAction.runBlock({()in self.setupThrowArea()})
                self.runAction(myFunction)
                score += 1
                scoreLabel.text = "\(score)"
                generateTargets()
            }
        }
        
    }
    
    func fingerDistanceFromProjectileRestPosition(projectileRestPosition: CGPoint, fingerPosition: CGPoint) -> CGFloat {
        return sqrt(pow(projectileRestPosition.x - fingerPosition.x,2) + pow(projectileRestPosition.y - fingerPosition.y,2))
    }
    
    func projectilePositionForFingerPosition(fingerPosition: CGPoint, projectileRestPosition:CGPoint, circleRadius rLimit:CGFloat) -> CGPoint {
        let φ = atan2(fingerPosition.x - projectileRestPosition.x, fingerPosition.y - projectileRestPosition.y)
        let cX = sin(φ) * rLimit
        let cY = cos(φ) * rLimit
        return CGPoint(x: cX + projectileRestPosition.x, y: cY + projectileRestPosition.y)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if gameOver{
            gameOverLabel.removeFromParent()
            startGameBtn.removeFromParent()
            startGame()
        }
        
        func shouldStartDragging(touchLocation:CGPoint, threshold: CGFloat) -> Bool {
            let distance = fingerDistanceFromProjectileRestPosition(
                Settings.Metrics.projectileRestPosition,
                fingerPosition: touchLocation
            )
            return distance < Settings.Metrics.projectileRadius + threshold
        }
        
        if let touch = touches.first {
            let touchLocation = touch.locationInNode(self)
            
            if !projectileIsDragged && shouldStartDragging(touchLocation, threshold: Settings.Metrics.projectileTouchThreshold)  {
                touchStartingPoint = touchLocation
                touchCurrentPoint = touchLocation
                projectileIsDragged = true
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if projectileIsDragged {
            if let touch = touches.first {
                let touchLocation = touch.locationInNode(self)
                let distance = fingerDistanceFromProjectileRestPosition(touchLocation, fingerPosition: touchStartingPoint)
                if distance < Settings.Metrics.rLimit  {
                    touchCurrentPoint = touchLocation
                } else {
                    touchCurrentPoint = projectilePositionForFingerPosition(
                        touchLocation,
                        projectileRestPosition: touchStartingPoint,
                        circleRadius: Settings.Metrics.rLimit
                    )
                }
                
            }
            orb.position = touchCurrentPoint
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if (!gameOver) {
            if projectileIsDragged {
                projectileIsDragged = false
                let distance = fingerDistanceFromProjectileRestPosition(touchCurrentPoint, fingerPosition: touchStartingPoint)
                if distance > Settings.Metrics.projectileSnapLimit {
                    let vectorX = touchStartingPoint.x - touchCurrentPoint.x
                    let vectorY = touchStartingPoint.y - touchCurrentPoint.y
                    orb.physicsBody!.affectedByGravity = true
                    orb.physicsBody?.applyImpulse(
                        CGVector(
                            dx: vectorX * Settings.Metrics.forceMultiplier,
                            dy: vectorY * Settings.Metrics.forceMultiplier
                        )
                    )
                } else {
                    orb.position = Settings.Metrics.projectileRestPosition
                }
            }
        }
    }
    
    func distanceBetweenTwoPoints(pointOne: CGPoint, pointTwo: CGPoint) -> CGFloat {
        return sqrt(pow(pointOne.x - pointTwo.x,2) + pow(pointOne.y - pointTwo.y,2))
    }
    
    func generateTargets(){
        
        if (!gameOver) {
            // Target Position
            let xPos = CGFloat( Float(arc4random()) / Float(UINT32_MAX)) * self.frame.size.width
            let yPos = CGFloat( Float(arc4random_uniform(UInt32(self.frame.size.height - self.frame.size.height/3))) + Float(self.frame.size.height/3))
            
            // Target
            target = SKShapeNode(ellipseOfSize: CGSize(width: Settings.Metrics.projectileRadius*2, height: Settings.Metrics.projectileRadius*4))
            target.physicsBody = SKPhysicsBody(polygonFromPath: CGPathCreateWithEllipseInRect(CGRectMake(-Settings.Metrics.projectileRadius, -Settings.Metrics.projectileRadius*2, Settings.Metrics.projectileRadius*2, Settings.Metrics.projectileRadius*4), nil))
            target.physicsBody!.dynamic = false
            target.physicsBody?.categoryBitMask = targetGroup
            target.physicsBody?.collisionBitMask = targetGroup
            target.physicsBody?.contactTestBitMask = orbGroup
            target.zPosition = 20
            target.position = CGPoint(x: xPos, y: yPos )
            let fadeIn = SKAction.colorizeWithColor(UIColor.blueColor(), colorBlendFactor: 0.5, duration: 2)
            let fadeOut = SKAction.colorizeWithColor(UIColor.clearColor(), colorBlendFactor: 0.5, duration: 2)
            let pulseTargetForever = SKAction.repeatActionForever(SKAction.sequence([fadeIn, fadeOut]))
            target.runAction(pulseTargetForever)

            targetObjects.addChild(target)
        }
    }
    
    func generateBarriers(){
        barrier1.position = CGPointMake(frame.midX, 250)

        barrier2.position = CGPointMake(100, 400)

        barrier3.position = CGPointMake(frame.width - 100, 550)
        
        barrierObjects.addChild(barrier1)
        barrierObjects.addChild(barrier2)
        barrierObjects.addChild(barrier3)
    }
    
    func startGame(){
        self.addChild(staticOrb)
        self.addChild(explosionEmitterNode)
        let fadeIn = SKAction.fadeInWithDuration(1.0)
        let fadeOut = SKAction.fadeOutWithDuration(1.0)
        let pulseOrbForever = SKAction.repeatActionForever(SKAction.sequence([fadeIn, fadeOut]))
        staticOrb.runAction(pulseOrbForever)
        gameOver = false
        score = 0
        scoreLabel.text = "\(score)"
        time = 20
        timerLabel.text = "\(time)"
        timeRepeat = true
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "countdown", userInfo: nil, repeats: timeRepeat)
        
        setupThrowArea()
        generateTargets()
        generateBarriers()
    }
    
    func stopGame(){
        movingObjects.removeAllChildren()
        staticOrb.removeFromParent()
        target.removeFromParent()
        explosionEmitterNode.removeFromParent()
        barrierObjects.removeAllChildren()
        
        // GameOver
        gameOverLabel.fontName = "Avenir-BlackOblique"
        gameOverLabel.fontColor = UIColor.cyanColor()
        gameOverLabel.fontSize = 60
        gameOverLabel.text = "Game Over"
        gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), frame.size.height*2/3)
        gameOverLabel.zPosition = 30
        self.addChild(gameOverLabel)
        
        // PlayButton
        startGameBtn = SKLabelNode(fontNamed: "Avenir-BlackOblique")
        startGameBtn.text = "Tap to play"
        startGameBtn.fontColor = UIColor.cyanColor()
        startGameBtn.fontSize = 42
        startGameBtn.position = CGPointMake(frame.size.width/2, frame.size.height*1/3)
        startGameBtn.name = "playButton"
        let fadeIn = SKAction.fadeInWithDuration(1.0)
        let fadeOut = SKAction.fadeOutWithDuration(1.0)
        let pulseForever = SKAction.repeatActionForever(SKAction.sequence([fadeIn, fadeOut]))
        startGameBtn.runAction(pulseForever)
        self.addChild(startGameBtn)
    }
    
    func countdown() {
        time -= 1
        timerLabel.text = "\(time)"
        if time == 0 {
            gameOver = true
            timeRepeat = false
            timer.invalidate()
            stopGame()
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        trail.particlePosition = orb.position
        
    }

}
