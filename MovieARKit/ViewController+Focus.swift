//
//  ViewController+Focus.swift
//  MovieARKit
//
//  Created by 권석기 on 1/18/25.
//

import Foundation
import ARKit

extension ViewController {
    func updateFocus() {
        if let camera = sceneView.session.currentFrame?.camera, case .normal = camera.trackingState,
           let query = self.getRaycastQuery(from: sceneView.center),
           let result = sceneView.session.raycast(query).first {
            if let pointerNode = sceneView.scene.rootNode.childNode(withName: "pointer", recursively: true) {
                pointerNode.simdTransform = result.worldTransform
            } else {
                let plane = SCNBox(width: 0.1, height: 0.01, length: 0.1, chamferRadius: 0)
                plane.firstMaterial?.diffuse.contents = UIColor.green.withAlphaComponent(0.8)
                let node = SCNNode(geometry: plane)
                node.name = "pointer"
                node.simdTransform = result.worldTransform
                sceneView.scene.rootNode.addChildNode(node)
            }
        }
    }
}
