//
//  AssetDetailViewController.swift
//  MovieARKit
//
//  Created by 권석기 on 1/6/25.
//

import UIKit
import ARKit
class AssetDetailViewController: UIViewController, ARSCNViewDelegate, SCNSceneRendererDelegate {
    let sceneView: ARSCNView = {
        let sceneView = ARSCNView()
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        return sceneView
    }()
    
    let rotateXtextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let rotateYtextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let rotateZtextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var scnNode: SCNNode!
    var isTextFieldEditing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        let scene = SCNScene()
        
        let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        
        sceneView.allowsCameraControl = true
        sceneView.delegate = self
        
        scnNode = SCNNode(geometry: box)
        scnNode.position = SCNVector3(0, 0, -0.5)
        
        sceneView.scene = scene
        sceneView.scene.rootNode.addChildNode(scnNode)
        setValue()
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func setupUI() {
        self.view.backgroundColor = .systemBackground
        sceneView.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        view.addSubview(rotateXtextField)
        view.addSubview(rotateYtextField)
        view.addSubview(rotateZtextField)
        view.addSubview(sceneView)
        rotateXtextField.delegate = self
        rotateYtextField.delegate = self
        rotateZtextField.delegate = self
        
        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.heightAnchor.constraint(equalToConstant: 300),
            
            rotateXtextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            rotateXtextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            rotateXtextField.topAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: 20),
            rotateXtextField.heightAnchor.constraint(equalToConstant: 50),
            
            rotateYtextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            rotateYtextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            rotateYtextField.topAnchor.constraint(equalTo: rotateXtextField.bottomAnchor, constant: 20),
            rotateYtextField.heightAnchor.constraint(equalToConstant: 50),
            
            rotateZtextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            rotateZtextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            rotateZtextField.topAnchor.constraint(equalTo: rotateYtextField.bottomAnchor, constant: 20),
            rotateZtextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func setValue() {
        guard let rotation = sceneView.pointOfView?.rotation else {
            return
        }
        rotateXtextField.text = "\(rotation.x)"
        rotateYtextField.text = "\(rotation.y)"
        rotateZtextField.text = "\(rotation.z)"
    }
    
    @objc func addTapped() {
        self.dismiss(animated: true)
    }
    
    func renderer(_ renderer: any SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard sceneView.pointOfView?.rotation != nil, !isTextFieldEditing else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            setValue()
        }
    }
}

extension AssetDetailViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text, let rotation = sceneView.pointOfView?.eulerAngles else {
            return
        }
        
        let newValue = (text as NSString).floatValue
        isTextFieldEditing = true
        if textField == rotateXtextField {
            scnNode.eulerAngles = SCNVector3(newValue, rotation.y, rotation.z)
        } else if textField == rotateYtextField {
            scnNode.eulerAngles = SCNVector3(rotation.x, newValue, rotation.z)
        } else if textField == rotateZtextField {
            scnNode.eulerAngles = SCNVector3(rotation.x, rotation.y, newValue)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isTextFieldEditing = false
    }
}
