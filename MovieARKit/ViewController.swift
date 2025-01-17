//
//  ViewController.swift
//  MovieARKit
//
//  Created by 권석기 on 1/5/25.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, SCNNodeRendererDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addButton: UIButton!
    
    private var currentNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        addNotification()
    }
    
    func removeNode(named: String) {
        sceneView.scene.rootNode.enumerateChildNodes { node, _ in
            if node.name == named {
                node.removeFromParentNode()
            }
        }
    }
    
    func setupScene() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.delegate = self
        sceneView.scene.rootNode.rendererDelegate = self
        sceneView.session.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    @objc func tapped(recognizer: UITapGestureRecognizer) {
        let touch = recognizer.location(in: sceneView)
        
        if let query = sceneView.raycastQuery(from: touch, allowing: .estimatedPlane, alignment: .any) {
            guard let result = sceneView.session.raycast(query).first else {
                return
            }
            self.loadGeometry(result)
        }
    }
    
    func loadGeometry(_ result: ARRaycastResult) {
        guard let currentNode = currentNode else {
            return
        }
        currentNode.position = SCNVector3(result.worldTransform.columns.3.x,
                                          result.worldTransform.columns.3.y,
                                          result.worldTransform.columns.3.z)
        self.sceneView.scene.rootNode.addChildNode(currentNode)
        self.currentNode = nil
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let arAssetListVC = ARAssetListViewController()
        let navVC = UINavigationController(rootViewController: arAssetListVC)
        self.present(navVC, animated: true)
    }
    
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(addModel), name: NSNotification.Name("addModel"), object: nil)
    }
    
    @objc func addModel(_ notification: Notification) {
        guard let filename = notification.object as? String else { return }
        let scene = SCNScene(named: filename)
        let node = scene?.rootNode.childNode(withName: "Geom", recursively: true)
        currentNode = node
    }
}

extension ViewController {
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !(anchor is ARPlaneAnchor) {
            return
        }
        
        guard let anchorPlane = anchor as? ARPlaneAnchor else { return }
        
        let plane = SCNBox(width: CGFloat(anchorPlane.planeExtent.width), height: 0.01, length: CGFloat(anchorPlane.planeExtent.height), chamferRadius: 0)
        plane.firstMaterial?.diffuse.contents = anchorPlane.classification.planeColor
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(0, -0.01 / 2, 0)
        planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeNode.geometry!))
        let textNode = makeTextNode(anchorPlane.classification.description)
        
        planeNode.name = anchor.identifier.uuidString
        planeNode.addChildNode(textNode)
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: any SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else { return }
        
        if !(anchor is ARPlaneAnchor) {
            return
        }
        
        if let planeNode = node.childNodes.first {
            if let planeGeometry = node.childNodes.first?.geometry as? SCNBox {
                if node.childNodes.first!.name != anchor.identifier.uuidString {
                    return
                }
                planeGeometry.firstMaterial?.diffuse.contents = anchorPlane.classification.planeColor.withAlphaComponent(0.8)
                    planeGeometry.width = CGFloat(anchorPlane.planeExtent.width)
                    planeGeometry.length = CGFloat(anchorPlane.planeExtent.height)
                    planeNode.position =  SCNVector3Make(anchorPlane.center.x, 0, anchorPlane.center.z)
                    planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry))
            }
        }
    }
    
    func renderer(_ renderer: any SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        
        sceneView.scene.rootNode.enumerateChildNodes { node, _ in
            if node.name == anchor.identifier.uuidString {
                print("Remove node")
                node.removeFromParentNode()
            }
        }
    }
    
    private func makeTextNode(_ text: String) -> SCNNode {
        let textGeometry = SCNText(string: text, extrusionDepth: 1)
        textGeometry.font = UIFont.systemFont(ofSize: 80)

        let textNode = SCNNode(geometry: textGeometry)
        // scale down the size of the text
        textNode.simdScale = float3(0.0005)
        
        return textNode
    }
}
