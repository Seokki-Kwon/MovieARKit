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
    
    lazy var focusImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame.size.width = 100
        imageView.frame.size.height = 200
        imageView.image = UIImage(named: "focus")
        return imageView
    }()
    lazy var coachingOverlay = ARCoachingOverlayView(frame: view.bounds)
    var currentNode: SCNNode?
    var scale: SCNVector3?
    var planes: [SCNNode] = []        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupUI()
        setupCoachingView()
    }
    
    func setupCoachingView() {
        sceneView.addSubview(coachingOverlay)
        coachingOverlay.session = sceneView.session
        coachingOverlay.delegate = self
        
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.activatesAutomatically = true
    }
    
    func setupScene() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
//        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        let panGesture = UIRotationGestureRecognizer(target: self, action: #selector(panned))
        sceneView.addGestureRecognizer(tapGesture)
//        sceneView.addGestureRecognizer(pinchGesture)
        sceneView.addGestureRecognizer(panGesture)
       
        sceneView.session.delegate = self
        sceneView.delegate = self
        sceneView.scene.rootNode.rendererDelegate = self
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    func setupUI() {
        sceneView.addSubview(focusImage)
        
        NSLayoutConstraint.activate([
            focusImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            focusImage.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func panned(recognizer: UIRotationGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
                                    
        }
    }
    
    @objc func pinch(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .changed {
            let scaleFactor = recognizer.scale
            scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        }
    }
    
    @objc func tapped(recognizer: UITapGestureRecognizer) {
        guard let currentNode = currentNode else { return }
        guard let query = getRaycastQuery(from: sceneView.center),
        let result = sceneView.session.raycast(query).first else { return }
        
        currentNode.simdTransform = result.worldTransform
        if let scale = scale {
            currentNode.scale = scale
        }
        self.sceneView.scene.rootNode.addChildNode(currentNode)
        self.currentNode = nil
    }
    
    func loadGeometry(_ result: ARRaycastResult) {
        guard let currentNode = currentNode else {
            return
        }
        currentNode.simdTransform = result.worldTransform
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
        addNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        removeNotification()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let arAssetListVC = ARAssetListViewController()
        let navVC = UINavigationController(rootViewController: arAssetListVC)
        self.present(navVC, animated: true)
    }
    
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(addModel), name: NSNotification.Name("addModel"), object: nil)
    }
    
    func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("addModel"), object: nil)
    }
    
    @objc func addModel(_ notification: Notification) {
        guard let filename = notification.object as? String else { return }
        let scene = SCNScene(named: filename)
        guard let node = scene?.rootNode.childNode(withName: "Geom", recursively: true) else { return }
        sceneView.scene.rootNode.addChildNode(node)
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
            self.updateObject()
        }
    }
}
