//
//  Scene.swift
//  SwiftOrb
//
//  Created by Jonathan Deehan on 06/05/2016.
//  Copyright © 2016 Mahogany Games. All rights reserved.
//

import SpriteKit

class Scene: SKScene {
    
    //MARK: Public functions expected to be overridden
    
    func screenInteractionStarted(location: CGPoint) {
        /* Overridden by Subclass */
    }
    
    func screenInteractionMoved(location: CGPoint) {
        /* Overridden by Subclass */
    }
    
    func screenInteractionEnded(location: CGPoint) {
        /* Overridden by Subclass */
    }
    
    func buttonEvent(event:String,velocity:Float,pushedOn:Bool) {
        /* Overridden by Subclass */
    }
    
    func stickEvent(event:String,point:CGPoint) {
        /* Overridden by Subclass */
    }
    
    //MARK: Camera functionality
    
    func centerCameraOnPoint(point: CGPoint) {
        if let camera = camera {
            camera.position = point
        }
    }
    
    //MARK: Localization
    
    func lt(text:String) -> String {
        return NSLocalizedString(text, comment: "")
    }
    
}
