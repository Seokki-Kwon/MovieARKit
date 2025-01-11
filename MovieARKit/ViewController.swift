//
//  ViewController.swift
//  MovieARKit
//
//  Created by 권석기 on 1/5/25.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addButton: UIButton!
    
    private var currentNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        addNotification()
    }
    
    func createFloor(anchor: ARPlaneAnchor) -> SCNNode {
        let floor = SCNNode()
        floor.name = "Floor"
        floor.eulerAngles = SCNVector3(90.degreesToRadinans, 0, 0)
        floor.geometry = SCNPlane(width: CGFloat(anchor.planeExtent.width), height: CGFloat(anchor.planeExtent.height))
        
        floor.geometry?.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.4)
        floor.geometry?.firstMaterial?.isDoubleSided = true
        floor.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        return floor
    }
    
    func removeNode(named: String) {
        sceneView.scene.rootNode.enumerateChildNodes { node, _ in
            if node.name == "Floor" {
                node.removeFromParentNode()
            }
        }
    }
    
    func setupScene() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.delegate = self
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
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
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
        // 장면에 새로운 ARAnchor 노드가 추가될때 호출
        guard let anchorPlane = anchor as? ARPlaneAnchor else { return }
        let floorNode = createFloor(anchor: anchorPlane)
        node.addChildNode(floorNode)
    }
    
    func renderer(_ renderer: any SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else { return }
        let floorNode = createFloor(anchor: anchorPlane)
        //        node.removeFromParentNode()
        node.addChildNode(floorNode)
    }
    
    func renderer(_ renderer: any SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        print("Remove node")
        removeNode(named: "Floor")
    }
}
