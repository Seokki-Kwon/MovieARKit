//
//  AssetCollectionViewCell.swift
//  MovieARKit
//
//  Created by 권석기 on 1/5/25.
//

import UIKit

class AssetCollectionViewCell: UICollectionViewCell {
    static let identifier = "AssetCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .green
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
