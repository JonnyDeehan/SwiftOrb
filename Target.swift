//
//  Goals.swift
//  SwiftOrb
//
//  Created by Jonathan Deehan on 19/05/2016.
//  Copyright © 2016 Mahogany Games. All rights reserved.
//

import SpriteKit

class Target: SKSpriteNode {
    
    init(){
        let texture = SKTexture(imageNamed: "target.png")
        
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
