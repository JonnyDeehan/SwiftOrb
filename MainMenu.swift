//
//  MainMenu.swift
//  SwiftOrb
//
//  Created by Jonathan Deehan on 06/05/2016.
//  Copyright © 2016 Mahogany Games. All rights reserved.
//

import SpriteKit

class MainMenu: Scene{
    
    var button: SKNode! = nil
    
    override func didMoveToView(view: SKView) {
        
        /* 
         Main Menu Appearance 
         */
        
        // Background
        self.backgroundColor = UIColor.darkGrayColor()
        
        // PlayButton
        let startGameBtn = SKLabelNode(fontNamed: "Avenir-BlackOblique")
        startGameBtn.text = "Tap to play"
        startGameBtn.fontColor = UIColor.cyanColor()
        startGameBtn.fontSize = 42
        startGameBtn.position = CGPointMake(frame.size.width/2, frame.size.height * 0.3)
        startGameBtn.name = "playButton"
        let fadeIn = SKAction.fadeInWithDuration(1.0)
        let fadeOut = SKAction.fadeOutWithDuration(1.0)
        let pulseForever = SKAction.repeatActionForever(SKAction.sequence([fadeIn, fadeOut]))
        startGameBtn.runAction(pulseForever)
        addChild(startGameBtn)
        
        // Title
        let title = SKLabelNode(fontNamed: "Avenir-BlackOblique")
        title.text = "SwiftOrb"
        title.fontColor = UIColor.cyanColor()
        title.fontSize = 60
        title.position = CGPointMake(frame.size.width/2, frame.size.height/2 + frame.size.height/3)
        addChild(title)
    }
    
    override func screenInteractionStarted(location: CGPoint) {
        for node in nodesAtPoint(location){
            if node.isKindOfClass(SKNode){
                // Detect Button pressed
                if node.name == "playButton" {
                    buttonEvent("buttonA", velocity: 1.0, pushedOn: true)
                }
            }
        }
    }
    
    override func buttonEvent(event: String, velocity: Float, pushedOn: Bool){
        if event == "buttonA" {
            // Move to next scene (GamePlayScene)
            let nextScene = GamePlayScene(size: self.scene!.size)
            nextScene.scaleMode = self.scaleMode
            self.view?.presentScene(nextScene)
        }
        
    }
    
}
