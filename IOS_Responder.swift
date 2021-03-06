//
//  IOS_Responder.swift
//  SwiftOrb
//
//  Created by Jonathan Deehan on 17/05/2016.
//  Copyright © 2016 Mahogany Games. All rights reserved.
//

import Foundation
import SpriteKit

extension Scene {
    
    /**
     Handle screen touch events.
     */
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            screenInteractionStarted(location)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            screenInteractionMoved(location)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            screenInteractionEnded(location)
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        
        if let actualTouches = touches {
            for touch: AnyObject in actualTouches {
                let location = touch.locationInNode(self)
                screenInteractionEnded(location)
            }
        }
    }
    
}
