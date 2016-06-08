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
    var orb = SKShapeNode()
    var staticOrb = SKSpriteNode()
    var ground = SKNode()
    var movingObjects = SKNode()
    var staticObjects = SKNode()
    var target = SKShapeNode()
    var barrier = SKSpriteNode()
    var scoreLabel = SKLabelNode()
    var timerLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var startGameBtn = SKLabelNode()
    let trailNode = SKNode()
    var trail = SKEmitterNode()
    // ====== CategoryBitMask ======
    var surfaceGroup:UInt32 = 2
    var orbGroup:UInt32 = 1
    var targetGroup:UInt32 = 3
    // ====== States ======
    // Game over state
    var gameOver = false
    var time = 20
    var timeRepeat:Bool = true
    // Pause State
    var pause = false
    var pauseLoop = false
    // ====== Score ======
    var score = 0
  
    var projectileIsDragged = false
    var touchCurrentPoint: CGPoint!
    var touchStartingPoint :CGPoint!
    
    var timer = NSTimer()
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        // Gravity
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = Settings.Game.gravity
        self.physicsWorld.speed = 1.5
        
        self.addChild(movingObjects)
        self.addChild(staticObjects)
        
        // Ground
        ground.position = CGPointMake(0,0.1)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width*3, 1))
        ground.physicsBody!.dynamic = false
        ground.physicsBody?.categoryBitMask = surfaceGroup
        self.addChild(ground)
        // Borders
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.friction = 0
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
        orb.physicsBody!.affectedByGravity = false
        orb.physicsBody?.allowsRotation = false
        orb.physicsBody?.categoryBitMask = orbGroup
        orb.physicsBody?.collisionBitMask = 3
        orb.physicsBody?.contactTestBitMask = surfaceGroup
        orb.strokeColor = UIColor.blueColor()
        
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
        trail = SKEmitterNode(fileNamed: "OrbTrail2")!
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
                target.removeFromParent()
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
            self.addChild(target)
        }
    }
    
    func generateBarriers(){
        
    }
    
    func startGame(){
        self.addChild(staticOrb)
        var orbTexArray = ["redball_20","redball_22","redball_24","redball_26","redball_28","redball_30"]
        var pulseOrb = SKAction.sequence(<#T##actions: [SKAction]##[SKAction]#>)
        staticOrb.runAction()
        gameOver = false
        score = 0
        scoreLabel.text = "\(score)"
        time = 20
        timerLabel.text = "\(time)"
        timeRepeat = true
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "countdown", userInfo: nil, repeats: timeRepeat)
        
        setupThrowArea()
        generateTargets()
        
    }
    
    func stopGame(){
        movingObjects.removeAllChildren()
        staticOrb.removeFromParent()
        target.removeFromParent()
        
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
        startGameBtn.fontColor = SKColor.purpleColor()
        startGameBtn.fontSize = 42
        startGameBtn.position = CGPointMake(frame.size.width/2, frame.size.height*1/3)
        startGameBtn.name = "playButton"
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
