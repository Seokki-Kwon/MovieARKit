//
//  ViewController.swift
//  MovieARKit
//
//  Created by 권석기 on 1/5/25.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addButton: UIButton!
    
    private var currentNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        addNotification()
    }
    
    func setupScene() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.delegate = self
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
        sceneView.session.run(configuration)
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
