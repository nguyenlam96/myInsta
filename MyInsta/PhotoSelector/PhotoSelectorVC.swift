//
//  PhotoSelectorVC.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/6/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import Photos

class PhotoSelectorVC: UICollectionViewController {
    
    // MARK: - Properties:
    
    var images: [UIImage] = []
    var selectedImage: UIImage?
    var assets: [PHAsset] = []
    var header: PhotoSelectorHeader?
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    // MARK: - ViewLifeCycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationButton()
        self.collectionView.backgroundColor = .white
        self.collectionView.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        self.collectionView.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellId)
        self.fetchPhoto()
        
    }
    
    // MARK: - Setup When ViewDidLoad:
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setupNavigationButton() {
        
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelButton))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNextButton))
    }
    
    private func assetFetchOptions() -> PHFetchOptions {
        
        let fetchOptions = PHFetchOptions()
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.fetchLimit = 30
        fetchOptions.sortDescriptors = [sortDescriptor]
        
        return fetchOptions
    }
    
    private func fetchPhoto() {
        
        let allPhotos = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: assetFetchOptions() )
        
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects { [unowned self](asset, count, stop) in
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: nil, resultHandler: { [unowned self](image, info) in
                    
                    if let image = image {
                        
                        self.images.append(image)
                        self.assets.append(asset)
                        
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                    } else {
                        LogUtils.LogDebug(type: .info, message: "Image at count: \(count) is nil")
                    }
                    
                    if count == self.images.count - 1 {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                    
                })
            }
        } // end background dispatch
        

    }
    
    
    // MARK: - Handle BarButtonitem :
    @objc func handleCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func handleNextButton() {
        
        let sharePhotoVC = SharePhotoVC()
            sharePhotoVC.selectedImage = self.header?.photoImageView.image
        self.navigationController?.pushViewController(sharePhotoVC, animated: true)
    }
    
}

extension PhotoSelectorVC: UICollectionViewDelegateFlowLayout {
    
    // MARK: - CollectionView Datasource:
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoSelectorCell
            cell.photoImageView.image = self.images[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    // MARK: - CollectionView Delegate :
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedImage = self.images[indexPath.row]
        self.collectionView.reloadData()
        
        let indexPath  = IndexPath(item: 0, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.bottom, animated: true)
    }
    
    // header:
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PhotoSelectorHeader
        
        self.header = header
        
        if let selectedImage = self.selectedImage {
            if let index = self.images.index(of: selectedImage) {
                let selectedAsset = self.assets[index]
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil) { (image, info) in
                    
                    header.photoImageView.image = image
                }
            }
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let width = self.view.frame.width
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    // cells:
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
}
