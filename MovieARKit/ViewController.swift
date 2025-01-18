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
    var planes: [SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        addNotification()
        setupCoachingView()
    }
        
    func setupCoachingView() {
        sceneView.addSubview(coachingOverlay)
        coachingOverlay.session = sceneView.session
        coachingOverlay.delegate = self
        
        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor),
            coachingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
    
    func getRaycastQuery(from point: CGPoint) -> ARRaycastQuery? {
        return sceneView.raycastQuery(from: point, allowing: .estimatedPlane, alignment: .any)
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
}
