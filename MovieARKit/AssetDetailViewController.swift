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
    
    lazy var rotateXtextFieldView: UIStackView = {
        let stView = UIStackView()
        let label = UILabel()
        stView.translatesAutoresizingMaskIntoConstraints = false
        label.text = "rotateX"
        stView.axis = .horizontal
        stView.distribution = .fillEqually
        stView.addArrangedSubview(label)
        stView.addArrangedSubview(rotateXtextField)
        return stView
    }()
    
    lazy var rotateYtextFieldView: UIStackView = {
        let stView = UIStackView()
        let label = UILabel()
        stView.translatesAutoresizingMaskIntoConstraints = false
        label.text = "rotateY"
        stView.axis = .horizontal
        stView.distribution = .fillEqually
        stView.addArrangedSubview(label)
        stView.addArrangedSubview(rotateYtextField)
        return stView
    }()
    
    lazy var rotateZtextFieldView: UIStackView = {
        let stView = UIStackView()
        let label = UILabel()
        stView.translatesAutoresizingMaskIntoConstraints = false
        label.text = "rotateZ"
        stView.axis = .horizontal
        stView.distribution = .fillEqually
        stView.addArrangedSubview(label)
        stView.addArrangedSubview(rotateZtextField)
        return stView
    }()
    
    lazy var resetButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "gobackward"), for: .normal)

        button.addTarget(self, action: #selector(resetValue), for: .touchUpInside)
        return button
    }()
    
    var scnNode: SCNNode!
    var isTextFieldEditing = false
    
    @objc func resetValue() {
        scnNode.eulerAngles = SCNVector3Zero
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tapGesture)
        
        self.view.backgroundColor = .systemBackground
        sceneView.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        
        view.addSubview(rotateXtextFieldView)
        view.addSubview(rotateYtextFieldView)
        view.addSubview(rotateZtextFieldView)
        view.addSubview(sceneView)
        view.addSubview(resetButton)
        
        rotateXtextField.delegate = self
        rotateYtextField.delegate = self
        rotateZtextField.delegate = self
        
        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.heightAnchor.constraint(equalToConstant: 300),
            
            resetButton.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor, constant: -20),
            resetButton.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: -20),
            
            rotateXtextFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            rotateXtextFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            rotateXtextFieldView.topAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: 20),
            
            rotateYtextFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            rotateYtextFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            rotateYtextFieldView.topAnchor.constraint(equalTo: rotateXtextFieldView.bottomAnchor, constant: 20),
            
            rotateZtextFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            rotateZtextFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            rotateZtextFieldView.topAnchor.constraint(equalTo: rotateYtextFieldView.bottomAnchor, constant: 20),
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
}

extension AssetDetailViewController: SCNSceneRendererDelegate {
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
