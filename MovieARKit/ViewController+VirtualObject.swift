//
//  ViewController+VirtualObject.swift
//  MovieARKit
//
//  Created by 권석기 on 1/20/25.
//

import Foundation
import ARKit

extension ViewController {
    func updateObject() {
        if let camera = sceneView.session.currentFrame?.camera, case .normal = camera.trackingState,
           let currentNode = currentNode,
           let query = self.getRaycastQuery(from: sceneView.center),
           let result = sceneView.session.raycast(query).first {
               currentNode.simdTransform = result.worldTransform     
//               if let scale = scale {
//                   currentNode.scale = scale
//               }
        }
    }
}
