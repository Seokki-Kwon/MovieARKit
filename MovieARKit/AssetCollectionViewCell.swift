//
//  AssetCollectionViewCell.swift
//  MovieARKit
//
//  Created by 권석기 on 1/5/25.
//

import UIKit

class AssetCollectionViewCell: UICollectionViewCell {
    static let identifier = "AssetCollectionViewCell"
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var assetData: SCNAsset? {
        didSet {
            self.nameLabel.text = assetData?.name
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.gray.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
