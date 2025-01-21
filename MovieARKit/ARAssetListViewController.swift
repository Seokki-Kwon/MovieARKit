//
//  ARAssetListViewController.swift
//  MovieARKit
//
//  Created by 권석기 on 1/5/25.
//

import UIKit

class ARAssetListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let width = (view.frame.width - 30) / 3 - (20 / 3)
        layout.minimumLineSpacing = 10 // vertical -> column
        layout.minimumInteritemSpacing = 10 // vertical -> row
        layout.itemSize = CGSize(width: width, height: width)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
      
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSearchBar()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search model"
        self.navigationItem.searchController = searchController
    }
    
    func setupView() {
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
        view.addSubview(collectionView)
        navigationItem.title = "Model"
        collectionView.register(AssetCollectionViewCell.self, forCellWithReuseIdentifier: AssetCollectionViewCell.identifier)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }       
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataset.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetCollectionViewCell.identifier, for: indexPath) as? AssetCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.assetData = dataset[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let assetDatilVC = AssetDetailViewController(sceneAsset: dataset[indexPath.row])
        self.navigationController?.pushViewController(assetDatilVC, animated: true)
    }
}
