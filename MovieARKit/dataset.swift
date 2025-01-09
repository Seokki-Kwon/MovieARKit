//
//  dataset.swift
//  MovieARKit
//
//  Created by 권석기 on 1/9/25.
//

import Foundation

struct SCNAsset {
    let name: String
    let filename: String
}

let dataset: [SCNAsset] = [
    SCNAsset(name: "shiba", filename: "art.scnassets/Shiba.scn"),
    SCNAsset(name: "chair", filename: "art.scnassets/chair.scn")
]
