//
//  GameScene.swift
//  SwiftOrb
//
//  Created by Jonathan Deehan on 06/05/2016.
//  Copyright (c) 2016 Mahogany Games. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let nextScene = MainMenu(size: self.scene!.size)
        nextScene.scaleMode = self.scaleMode
        self.view?.presentScene(nextScene)
    }
    
}
