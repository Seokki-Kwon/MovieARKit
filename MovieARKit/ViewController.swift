//
//  ViewController.swift
//  MovieARKit
//
//  Created by 권석기 on 1/5/25.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNNodeRendererDelegate, ARCoachingOverlayViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addButton: UIButton!
    lazy var coachingOverlay = ARCoachingOverlayView(frame: view.bounds)
    private var currentNode: SCNNode?
    private var planes: [SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        addNotification()
        setupCoachingView()
    }
    
    func updateFocus() {
        if let camera = sceneView.session.currentFrame?.camera, case .normal = camera.trackingState,
           let query = self.getRaycastQuery(from: sceneView.center),
           let result = sceneView.session.raycast(query).first {
                if let pointerNode = sceneView.scene.rootNode.childNode(withName: "pointer", recursively: true) {
                    pointerNode.simdTransform = result.worldTransform
                } else {
                    let plane = SCNBox(width: 0.2, height: 0.01, length: 0.2, chamferRadius: 0)
                    plane.firstMaterial?.diffuse.contents = UIColor.green.withAlphaComponent(0.8)
                    let node = SCNNode(geometry: plane)
                    node.eulerAngles.x = .pi / 2
                    node.name = "pointer"
                    node.simdTransform = result.worldTransform
                    sceneView.scene.rootNode.addChildNode(node)
                }
            }
    }
    
    func setupCoachingView() {
        sceneView.addSubview(coachingOverlay)
        coachingOverlay.session = sceneView.session
        coachingOverlay.delegate = self
        
        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.activatesAutomatically = true
    }
    
    func setupScene() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.session.delegate = self
        sceneView.delegate = self
        sceneView.scene.rootNode.rendererDelegate = self
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
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
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
        //        let arAssetListVC = ARAssetListViewController()
        //        let navVC = UINavigationController(rootViewController: arAssetListVC)
        //        self.present(navVC, animated: true)
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

extension ViewController {
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //        guard let planeNode = createPlane(for: anchor) else { return }
        //        planes.append(planeNode)
        //        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: any SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        //        self.updatePlane(for: anchor)
    }
    
    func renderer(_ renderer: any SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        sceneView.scene.rootNode.enumerateChildNodes { node, _ in
            if node.name == anchor.identifier.uuidString {
                print("Remove node")
                node.removeFromParentNode()
            }
        }
    }
}

extension ViewController: ARSessionDelegate {
    
    func renderer(_ renderer: any SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if coachingOverlay.isActive {
            return
        }
        
        DispatchQueue.main.async {
            self.updateFocus()
        }
    }
    
    func getRaycastQuery(from point: CGPoint) -> ARRaycastQuery? {
        return sceneView.raycastQuery(from: point, allowing: .estimatedPlane, alignment: .any)
    }
}
