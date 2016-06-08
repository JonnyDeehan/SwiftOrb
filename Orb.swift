//
//  Orb.swift
//  SwiftOrb
//
//  Created by Jonathan Deehan on 26/05/2016.
//  Copyright © 2016 Mahogany Games. All rights reserved.
//

import SpriteKit

class Orb: SKShapeNode {
    
    convenience init(path: UIBezierPath, color: UIColor, borderColor:UIColor, position: CGPoint){
        self.init()
        self.path = path.CGPath
        self.fillColor = color
        self.strokeColor = borderColor
        self.position = CGPoint(x: 187.5, y: 100)
        
    }
    
    
}
