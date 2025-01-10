//
//  AssetCollectionViewCell.swift
//  MovieARKit
//
//  Created by 권석기 on 1/5/25.
//

import UIKit
import ARKit

class AssetCollectionViewCell: UICollectionViewCell, ARSCNViewDelegate {
    static let identifier = "AssetCollectionViewCell"
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var assetData: SCNAsset? {
        didSet {
            setupUI()
        }
    }
    
    func setupUI() {
        self.nameLabel.text = assetData?.name
        self.imageView.image = assetData?.makeSnapshot()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
        ])
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.darkGray.cgColor
        contentView.layer.cornerRadius = 4
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
