//
//  dataset.swift
//  MovieARKit
//
//  Created by 권석기 on 1/9/25.
//

import Foundation
import ARKit

struct SCNAsset {
    let name: String
    let filename: String    
    
    func makeSnapshot() -> UIImage {
        let scene = SCNScene(named: filename)
        let renderer = SCNRenderer(context: nil)
        renderer.autoenablesDefaultLighting = true
        renderer.scene = scene
        let image = renderer.snapshot(atTime: 0, with: .init(width: 100, height: 100), antialiasingMode: .multisampling4X)
        
        return image
    }
}

let dataset: [SCNAsset] = [
    SCNAsset(name: "shiba", filename: "art.scnassets/Shiba.scn"),
    SCNAsset(name: "chair", filename: "art.scnassets/chair.scn"),
    SCNAsset(name: "chair", filename: "art.scnassets/chair.scn"),
    SCNAsset(name: "chair", filename: "art.scnassets/chair.scn"),
]
