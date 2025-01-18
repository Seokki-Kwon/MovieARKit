//
//  ViewController+PlaneDetection.swift
//  MovieARKit
//
//  Created by 권석기 on 1/18/25.
//

import Foundation
import ARKit

extension ViewController {
    func createPlane(for anchor: ARAnchor) -> SCNNode? {
        guard let anchorPlane = anchor as? ARPlaneAnchor, anchor is ARPlaneAnchor else {
            return nil
        }
        
        let plane = SCNBox(width: CGFloat(anchorPlane.planeExtent.width), height: 0.01, length: CGFloat(anchorPlane.planeExtent.height), chamferRadius: 0)
        plane.firstMaterial?.diffuse.contents = anchorPlane.classification.planeColor
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(0, -0.01 / 2, 0)
        planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeNode.geometry!))
        
        planeNode.name = anchor.identifier.uuidString
        
        return planeNode
    }
    
    func updatePlane(for anchor: ARAnchor) {
        if !(anchor is ARPlaneAnchor) {
            return
        }
        guard let anchorPlane = anchor as? ARPlaneAnchor,
              let planeNode = planes.first(where: { $0.name == anchor.identifier.uuidString }),
              let planeGeometry = planeNode.geometry as? SCNBox else {
            return
        }
        
        planeGeometry.firstMaterial?.diffuse.contents = anchorPlane.classification.planeColor.withAlphaComponent(0.8)
        planeGeometry.width = CGFloat(anchorPlane.planeExtent.width)
        planeGeometry.length = CGFloat(anchorPlane.planeExtent.height)
        planeNode.position =  SCNVector3Make(anchorPlane.center.x, 0, anchorPlane.center.z)
        planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry))
    }
    
    private func makeTextNode(_ text: String) -> SCNNode {
        let textGeometry = SCNText(string: text, extrusionDepth: 1)
        textGeometry.font = UIFont.systemFont(ofSize: 80)
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.eulerAngles = .init(0, 0, 0)
        // scale down the size of the text
        textNode.simdScale = float3(0.0005)
        return textNode
    }
}
