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
        imageView.frame.size.height = 100
        imageView.image = UIImage(named: "focus")
        return imageView
    }()
    lazy var coachingOverlay = ARCoachingOverlayView(frame: view.bounds)
    var currentNode: SCNNode?
    var tempNode: SCNNode?
    var scale: SCNVector3?
    var rotate: Float?
    var localTranslate: CGPoint!
    var planes: [SCNNode] = []
    
    // LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupUI()
        setupCoachingView()
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
    
    func setupCoachingView() {
        sceneView.addSubview(coachingOverlay)
        coachingOverlay.session = sceneView.session
        coachingOverlay.delegate = self
        
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.activatesAutomatically = true
    }
    
    func setupScene() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        let panGesture = UIRotationGestureRecognizer(target: self, action: #selector(panned))
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        longPressGesture.minimumPressDuration = 0.1
        
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.addGestureRecognizer(longPressGesture)
        sceneView.addGestureRecognizer(pinchGesture)
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
    
    // Handler
    @objc func longPress(recognizer: UILongPressGestureRecognizer) {
        guard let tempNode = tempNode else { return }
        let touch = recognizer.location(in: sceneView)
            
            if recognizer.state == .began {
                localTranslate = touch
            }
            else if recognizer.state == .changed {
                let deltaX = Float(touch.x - self.localTranslate.x) / 700
                let deltaY = Float(touch.y - self.localTranslate.y) / 700
                
                tempNode.localTranslate(by: SCNVector3(deltaX, 0.0, deltaY))
                self.localTranslate = touch
            }
    }
    
    @objc func panned(recognizer: UIRotationGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let rotate = Float(recognizer.rotation)
            self.rotate = rotate
        }
    }
    
    @objc func pinch(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .changed {
            let scaleFactor = recognizer.scale
            scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        }
    }
    
    @objc func tapped(recognizer: UITapGestureRecognizer) {
        if currentNode != nil && tempNode == nil {
            attachNode()
        } else if tempNode == nil {
            let touch = recognizer.location(in: sceneView)
            findNode(touch)
        } else if tempNode != nil {
            clearNode()
        }
    }
    
    @objc func addModel(_ notification: Notification) {
        guard let filename = notification.object as? String else { return }
        let scene = SCNScene(named: filename)
        guard let node = scene?.rootNode.childNode(withName: "Geom", recursively: true) else { return }
        sceneView.scene.rootNode.addChildNode(node)
        currentNode = node
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
