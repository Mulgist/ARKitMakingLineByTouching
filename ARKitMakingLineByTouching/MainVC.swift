//
//  MainVC.swift
//  ARKitMakingLineByTouching
//
//  Created by 이주원 on 2018. 4. 2..
//  Copyright © 2018년 이주원. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class MainVC: UIViewController, ARSCNViewDelegate {
    
    // Outlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var eulerAngleLbl: UILabel!
    @IBOutlet weak var xPlusButton: UIButton!
    @IBOutlet weak var xMinusButton: UIButton!
    @IBOutlet weak var yPlusButton: UIButton!
    @IBOutlet weak var yMinusButton: UIButton!
    @IBOutlet weak var zPlusButton: UIButton!
    @IBOutlet weak var zMinusButton: UIButton!
    
    var positions: [SCNVector3] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        
        // sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.antialiasingMode = SCNAntialiasingMode.multisampling4X
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapRecognizer)
        
        distanceLbl.text = ""
        
        let gesture1 = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        let gesture2 = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        let gesture3 = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        let gesture4 = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        let gesture5 = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        let gesture6 = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        
        gesture1.minimumPressDuration = 0.1
        gesture2.minimumPressDuration = 0.1
        gesture3.minimumPressDuration = 0.1
        gesture4.minimumPressDuration = 0.1
        gesture5.minimumPressDuration = 0.1
        gesture6.minimumPressDuration = 0.1
        
        xPlusButton.addGestureRecognizer(gesture1)
        xMinusButton.addGestureRecognizer(gesture2)
        yPlusButton.addGestureRecognizer(gesture3)
        yMinusButton.addGestureRecognizer(gesture4)
        zPlusButton.addGestureRecognizer(gesture5)
        zMinusButton.addGestureRecognizer(gesture6)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.isAutoFocusEnabled = true
        configuration.isLightEstimationEnabled = true

        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .featurePoint)
        if let result = hitTestResults.first {
            let position = SCNVector3.positionFrom(matrix: result.worldTransform)
            
            let firstPoint = positions.last
            positions.append(position)
            
            if let first = firstPoint {
                let length = first.distance(to: position)
                
                let box = BoxNode(position: first, length: length)
                
                let dx = position.x - first.x
                let dy = position.y - first.y
                let dz = position.z - first.z
                
                print("---------------------------------")
                print("First point")
                print(String(format: "x: %.3f, y: %.3f, z: %.3f", first.x, first.y, first.z))
                
                print("Second point")
                print(String(format: "x: %.3f, y: %.3f, z: %.3f", position.x, position.y, position.z))
                
                print("Variance")
                print(String(format: "x: %.3f, y: %.3f, z: %.3f", dx, dy, dz))
                
                // Finding the angles between two points
                var angleX = atan2(abs(dy), abs(dz))
                print(String(format: "absolute X angle: %.2f", angleX / Float.pi * 180))
                // X angle
                if dz > 0 && dy > 0 {
                    // angleX = angleX
                } else if dz < 0 && dy > 0 {
                    // angleX = angleX
                } else if dz > 0 && dy < 0 {
                    angleX = -angleX
                } else {
                    angleX = -angleX
                }
                if dx > 0 {
                    angleX = -angleX
                }
                
                var angleY = atan2(abs(dz), abs(dx))
                print(print(String(format: "absolute Y angle: %.2f", angleY / Float.pi * 180)))
                // Y angle
                if dx > 0 && dz > 0 {
                    angleY = -angleY
                } else if dx < 0 && dz > 0 {
                    // angleY = angleY
                } else if dx > 0 && dz < 0 {
                    // angleY = angleY
                } else {
                    angleY = -angleY
                }
                angleY += .pi / 2
                
                var angleZ = atan2(abs(dy), abs(dx))
                print(String(format: "absolute Z angle: %.2f", angleZ / Float.pi * 180))
                // Z angle
                if dx > 0 && dy > 0 {
                    angleZ = -angleZ
                } else if dx < 0 && dy > 0 {
                    // angleZ = angleZ
                } else if dx > 0 && dy < 0 {
                    // angleZ = angleZ
                } else {
                    angleZ = -angleZ
                }
                
                if abs(dx) < abs(dz) {
                    box.eulerAngles = SCNVector3(x: angleX, y: angleY, z: 0.0)
                } else {
                    box.eulerAngles = SCNVector3(x: angleZ, y: angleY, z: 0.0)
                }
                
                box.position = SCNVector3(x: (position.x + first.x) / 2, y: (position.y + first.y) / 2, z: (position.z + first.z) / 2)
                
                print("Box's position:")
                print(String(format: "x: %.3f, y: %.3f, z: %.3f", box.position.x, box.position.y, box.position.z))
                print("Box's Euler angles(Degree):")
                print(String(format: "x: %.2f, y: %.2f, z: %.2f", box.eulerAngles.x / Float.pi * 180, box.eulerAngles.y / Float.pi * 180, box.eulerAngles.z / Float.pi * 180))
                
                box.name = "box"
                self.sceneView.scene.rootNode.addChildNode(box)
                
                let sphere = SphereNode(position: position)
                
                sphere.name = "point2"
                
                self.sceneView.scene.rootNode.addChildNode(sphere)
                self.sceneView.scene.rootNode.addChildNode(sphere)
                
                self.distanceLbl.text = String(format: "Distance: %.3fm", length)
                
                self.eulerAngleLbl.text = String(format: "X: %.2f\nY: %.2f\nZ: %.2f", box.eulerAngles.x / .pi * 180, box.eulerAngles.y / .pi * 180, box.eulerAngles.z / .pi * 180)
                
                positions.removeAll()
            } else {
                self.sceneView.scene.rootNode.childNode(withName: "box", recursively: false)?.removeFromParentNode()
                self.sceneView.scene.rootNode.childNode(withName: "point1", recursively: false)?.removeFromParentNode()
                self.sceneView.scene.rootNode.childNode(withName: "point2", recursively: false)?.removeFromParentNode()
                self.distanceLbl.text = "Ready"
                self.eulerAngleLbl.text = "Euler Angles"
                
                let sphere = SphereNode(position: position)
                sphere.name = "point1"
                self.sceneView.scene.rootNode.addChildNode(sphere)
            }
        }
    }
    
    @objc func onLongPress(_ gesture: UILongPressGestureRecognizer) {
        let node = sceneView.scene.rootNode.childNode(withName: "box", recursively: true)
        
        if let selectedBox = node {
            if gesture.state == .ended {
                selectedBox.removeAllActions()
                self.eulerAngleLbl.text = String(format: "X: %.2f\nY: %.2f\nZ: %.2f", selectedBox.eulerAngles.x / .pi * 180, selectedBox.eulerAngles.y / .pi * 180, selectedBox.eulerAngles.z / .pi * 180)
            } else if gesture.state == .began {
                if gesture.view === xPlusButton {
                    let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: CGFloat(1 / 180 * Float.pi), y:0, z: 0, duration: 0.03))
                    selectedBox.runAction(rotate)
                } else if gesture.view === xMinusButton {
                    let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: CGFloat(-1 / 180 * Float.pi), y:0, z: 0, duration: 0.03))
                    selectedBox.runAction(rotate)
                } else if gesture.view === yPlusButton {
                    let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y:CGFloat(1 / 180 * Float.pi), z: 0, duration: 0.03))
                    selectedBox.runAction(rotate)
                } else if gesture.view === yMinusButton {
                    let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y:CGFloat(-1 / 180 * Float.pi), z: 0, duration: 0.03))
                    selectedBox.runAction(rotate)
                } else if gesture.view === zPlusButton {
                    let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y:0, z: CGFloat(1 / 180 * Float.pi), duration: 0.03))
                    selectedBox.runAction(rotate)
                } else if gesture.view === zMinusButton {
                    let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x:0, y:0, z: CGFloat(-1 / 180 * Float.pi), duration: 0.03))
                    selectedBox.runAction(rotate)
                }
            }
        }
    }

    // MARK: - ARSCNViewDelegate
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        var status = "Loading..."
        switch camera.trackingState {
        case ARCamera.TrackingState.normal:
            status = "Ready"
        case ARCamera.TrackingState.limited(_):
            status = "Analyzing..."
        case ARCamera.TrackingState.notAvailable:
            status = "Not Available"
        }
        distanceLbl.text = status
    }
}

extension SCNVector3 {
    func distance(to destination: SCNVector3) -> CGFloat {
        // x, y, z are positions of first point
        let dx = destination.x - x
        let dy = destination.y - y
        let dz = destination.z - z
        return CGFloat(sqrt(dx*dx + dy*dy + dz*dz))
    }
    
    static func positionFrom(matrix: matrix_float4x4) -> SCNVector3 {
        let column = matrix.columns.3
        return SCNVector3(column.x, column.y, column.z)
    }
}
