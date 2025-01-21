//
//  ViewController+VirtualObject.swift
//  MovieARKit
//
//  Created by 권석기 on 1/20/25.
//

import Foundation
import ARKit

extension ViewController {
    // 포커스에 맞춰서 위치업데이트
    func updateObject() {
        if let camera = sceneView.session.currentFrame?.camera, case .normal = camera.trackingState,
           let currentNode = currentNode,
           let query = self.getRaycastQuery(from: sceneView.center),
           let result = sceneView.session.raycast(query).first {
               currentNode.simdTransform = result.worldTransform     
               if let scale = scale {
                   currentNode.scale = scale
               }
            if let rotate = rotate {
                currentNode.eulerAngles.y -= rotate
            }
        }
    }
    
    // 선택된노드 제거
    func clearNode() {
        tempNode?.opacity = 1.0
        tempNode = nil
    }
    
    // 위치수정시 노드위치 찾기
    func findNode(_ point: CGPoint) {
        let hitTestResult = sceneView.hitTest(point, options: nil)
        guard let hitTest = hitTestResult.first else { return }
        hitTest.node.opacity = 0.8
        tempNode = hitTest.node
    }
    
    // 노드추가
    func attachNode() {
        guard let currentNode = currentNode,
              let query = getRaycastQuery(from: sceneView.center),
              let result = sceneView.session.raycast(query).first else { return }
        
        currentNode.simdTransform = result.worldTransform
        if let scale = scale {
            currentNode.scale = scale
        }
        if let rotate = rotate {
            currentNode.eulerAngles.y -= rotate
        }
        self.sceneView.scene.rootNode.addChildNode(currentNode)
        self.currentNode = nil
        self.scale = nil
        self.rotate = nil
    }
    
    func getRaycastQuery(from point: CGPoint) -> ARRaycastQuery? {
        return sceneView.raycastQuery(from: point, allowing: .estimatedPlane, alignment: .any)
    }
}
