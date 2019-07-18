//
//  ViewController.swift
//  trialAR
//
//  Created by Cherlia Brightokta on 17/07/19.
//  Copyright © 2019 Cherlia Brightokta. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var object: SCNNode?
    var currentAngleY: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.autoenablesDefaultLighting = true
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Create a new scene
        _ = SCNScene(named: "art.scnassets/ship.scn")!
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
//        sceneView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        panGesture.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGesture)
        
        let rotateGesture = UIPanGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        rotateGesture.minimumNumberOfTouches = 2
        sceneView.addGestureRecognizer(rotateGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        sceneView.addGestureRecognizer(pinchGesture)
        
        
        // Set the scene to the view
//        sceneView.scene = scene
        
//MARK
        //LINK GESTURE AR
        //www.yudiz.com/the-simple-steps-to-virtual-object-interaction-using-arkit/
        
        
        // LINK AR LAINNYA
    //mobile-ar.reality.news/how-to/arkit-101-pilot-your-3d-plane-location-using-hittest-arkit-0184060/
    //mobile-ar.reality.news/how-to/arkit-101-place-grass-ground-using-plane-detection-0184557/
    }
    
    
  
   
   @objc func didPinch(_ gesture: UIPinchGestureRecognizer) {
    if gesture.state == .changed {
        guard let sceneView = gesture.view as? ARSCNView else {
            return
        }
        let touch = gesture.location(in: sceneView)
        
        let hitTestResults = self.sceneView.hitTest(touch, options: nil)
        
        if let hitTest = hitTestResults.first {
            let shipNode  = hitTest.node
            
            let pinchScaleX = Float (gesture.scale) * shipNode.scale.x
            let pinchScaleY = Float (gesture.scale) * shipNode.scale.y
            let pinchScaleZ = Float (gesture.scale) * shipNode.scale.z

            shipNode.scale = SCNVector3(pinchScaleX,pinchScaleY,pinchScaleZ)
            gesture.scale = 1
            
        }
        
    }
    
    
//        guard let _ = object else { return }
//        var originalScale = object?.scale
//
//        switch gesture.state {
//        case .began:
//            originalScale = object?.scale
//            gesture.scale = CGFloat((object?.scale.x)!)
//        case .changed:
//            guard var newScale = originalScale else { return }
//            if gesture.scale < 0.5{ newScale = SCNVector3(x: 0.5, y: 0.5, z: 0.5) }else if gesture.scale > 2{
//                newScale = SCNVector3(2, 2, 2)
//            }else{
//                newScale = SCNVector3(gesture.scale, gesture.scale, gesture.scale)
//            }
//            object?.scale = newScale
//        case .ended:
//            guard var newScale = originalScale else { return }
//            if gesture.scale < 0.5{ newScale = SCNVector3(x: 0.5, y: 0.5, z: 0.5) }else if gesture.scale > 2{
//                newScale = SCNVector3(2, 2, 2)
//            }else{
//                newScale = SCNVector3(gesture.scale, gesture.scale, gesture.scale)
//            }
//            object?.scale = newScale
//            gesture.scale = CGFloat((object?.scale.x)!)
//        default:
//            gesture.scale = 1.0
//            originalScale = nil
//        }
    }
    
   @objc func didRotate(_ gesture: UIPanGestureRecognizer) {
        guard let _ = object else { return }
        let translation = gesture.translation(in: gesture.view)
        var newAngleY = (Float)(translation.x)*(Float)(Double.pi)/180.0
        
        newAngleY += currentAngleY
        object?.eulerAngles.y = newAngleY
        
        if gesture.state == .ended{
            currentAngleY = newAngleY
        }
    }
    
    @objc func didPan(_ gesture: UIPanGestureRecognizer){
        guard let object = object else {return}
        let panLocation = gesture.location(in: sceneView)
        let results = sceneView.hitTest(panLocation, types: .existingPlaneUsingExtent)
        
        
        
        if let result = results.first {
            let translation = result.worldTransform.translation
            object.position = SCNVector3Make(translation.x, translation.y, translation.z)
           sceneView.scene.rootNode.addChildNode(object)
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        infoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        infoLabel.text = "Session interruption ended"
        resetTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        infoLabel.text = "Session failed: \(error.localizedDescription)"
        resetTracking()
    }
    
    func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        // help us inform the user when the app is ready
        switch camera.trackingState {
        case .normal :
            infoLabel.text = "Move the device to detect horizontal surfaces."
            
        case .notAvailable:
            infoLabel.text = "Tracking not available."
            
        case .limited(.excessiveMotion):
            infoLabel.text = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            infoLabel.text = "Tracking limited - Point the device at an area with visible surface detail."
            
        case .limited(.initializing):
            infoLabel.text = "Initializing AR session."
            
        default:
            infoLabel.text = ""
        }
    }

    // MARK: - ARSCNView delegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Called when any node has been added to the anchor
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.infoLabel.text = "Surface Detected."
            
        }
        
        
        if object == nil {
            let shoesScene = SCNScene(named: "ship.scn", inDirectory: "art.scnassets")
            object = shoesScene?.rootNode.childNode(withName: "shipMesh", recursively: true)
            object?.simdPosition = float3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
            guard let object = object else {return}
            sceneView.scene.rootNode.addChildNode(object)
            node.addChildNode(object)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        // This method will help when any node has been removed from sceneview
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
        // Called when any node has been updated with data from anchor
    }
    
   
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    


extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

