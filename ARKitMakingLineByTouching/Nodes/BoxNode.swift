//
//  BoxNode.swift
//  ARKitMakingLineByTouching
//
//  Created by 이주원 on 2018. 4. 2..
//  Copyright © 2018년 이주원. All rights reserved.
//

import Foundation

import SceneKit

class BoxNode: SCNNode {
    init(position: SCNVector3, length: CGFloat) {
        super.init()
        let boxGeometry = SCNBox(width: 0.005, height: 0.005, length: length, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        material.lightingModel = .physicallyBased
        boxGeometry.materials = [material]
        self.geometry = boxGeometry
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
