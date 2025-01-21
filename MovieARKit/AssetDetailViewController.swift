//
//  AssetDetailViewController.swift
//  MovieARKit
//
//  Created by 권석기 on 1/6/25.
//

import UIKit
import ARKit
class AssetDetailViewController: UIViewController, ARSCNViewDelegate {
    let sceneView: ARSCNView = {
        let sceneView = ARSCNView()
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        return sceneView
    }()
    
    lazy var resetButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "gobackward"), for: .normal)

        button.addTarget(self, action: #selector(resetValue), for: .touchUpInside)
        return button
    }()
    
    var scnNode: SCNNode!    
    let assetData: SCNAsset
    
    init(sceneAsset: SCNAsset) {
        self.assetData = sceneAsset
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func resetValue() {
//        scnNode.eulerAngles = SCNVector3Zero
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupScene()
    }
    
    func setupScene() {
        sceneView.allowsCameraControl = true
        sceneView.delegate = self
        
        let rootScene = SCNScene()
        let childScene = SCNScene(named: assetData.filename)!
        
        let sceneNode2 = childScene.rootNode.childNode(withName: "Geom", recursively: true)
        sceneNode2?.position = SCNVector3(0, 0, -0.5)
        
        sceneView.autoenablesDefaultLighting = true
        rootScene.rootNode.addChildNode(sceneNode2!)
        sceneView.scene = rootScene
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tapGesture)
        
        self.view.backgroundColor = .systemBackground
        sceneView.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
 
        view.addSubview(sceneView)
        view.addSubview(resetButton)
        
        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.heightAnchor.constraint(equalToConstant: 300),
            
            resetButton.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor, constant: -20),
            resetButton.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: -20)                 
        ])
    }
    
    @objc func addTapped() {
        NotificationCenter.default.post(name: NSNotification.Name("addModel"), object: assetData.filename)
        self.dismiss(animated: true)
    }
}
