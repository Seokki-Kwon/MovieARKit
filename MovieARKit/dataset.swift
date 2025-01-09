//
//  dataset.swift
//  MovieARKit
//
//  Created by 권석기 on 1/9/25.
//

import Foundation

struct AssetData {
    let name: String
    let filename: String
}

let dataset: [AssetData] = [
    AssetData(name: "shiba", filename: "art.scnassets/Shiba.scn"),
    AssetData(name: "chair", filename: "art.scnassets/chair.scn")
]
