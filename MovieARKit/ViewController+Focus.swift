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
            // 포커스 노드가 존재하는경우 위치업데이트            
            if let pointerNode = sceneView.scene.rootNode.childNode(withName: "pointer", recursively: true) {
                pointerNode.simdTransform = result.worldTransform
                resizeFocus(for: pointerNode, camera: camera)
            } else {
                // 포커스노드 생성
                let plane = SCNBox(width: 0.2, height: 0.001, length: 0.2, chamferRadius: 0)
                plane.firstMaterial?.diffuse.contents = UIImage(named: "focus")
                let node = SCNNode(geometry: plane)
                node.name = "pointer"
                node.simdTransform = result.worldTransform
                sceneView.scene.rootNode.addChildNode(node)
            }
        }
    }
    
    func resizeFocus(for node: SCNNode, camera: ARCamera) {
        guard let planeGeometry = node.geometry as? SCNBox else { return }
        let cameraPosition = simd_make_float3(camera.transform.columns.3)
        let nodePosition = simd_make_float3(node.simdTransform.columns.3)
        let distance = simd_length(cameraPosition - nodePosition)
        // 거리가 늘어난다 -> 크기 확대
        // 거리가 줄어든다 -> 크기 축소
        let scaledWidth = CGFloat(0.2 * distance)
        planeGeometry.width = scaledWidth
        planeGeometry.length = scaledWidth
    }
}
