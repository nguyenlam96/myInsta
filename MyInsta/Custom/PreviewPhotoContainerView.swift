//
//  PreviewPhotoContainerView.swift
//  MyInsta
//
//  Created by Nguyen Lam on 3/1/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {
    
    
    //MARK: -
    let previewPhotoView: UIImageView = {
        let iv = UIImageView()
        
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
            button.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func handleCancelButtonTapped() {
        self.removeFromSuperview()
    }
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "save_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSaveButtonTapped), for: .touchUpInside)
        return button
    }()
    @objc func handleSaveButtonTapped() {
        Logger.LogDebug(type: .info, message: "\(#function)")
        guard let image = self.previewPhotoView.image else {
            Logger.LogDebug(type: .error, message: "image is empty")
            return
        }
        // save photo to library (async in background)
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { [unowned self](success, error) in
            if let error = error {
                Logger.LogDebug(type: .error, message: error.localizedDescription)
                return
            }
            // present popup after save success:
            DispatchQueue.main.async {
                let savedLabel = UILabel()
                savedLabel.text = "Saved!"
                savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
                savedLabel.textColor = .white
                savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.4)
                savedLabel.frame = CGRect(x: 0, y: 0, width: 75, height: 40)
                savedLabel.center = self.center
                savedLabel.textAlignment = .center
                savedLabel.numberOfLines = 0
                self.addSubview(savedLabel)
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                
            UIView.animate(withDuration: 0.5, delay: 0.5, options: [.curveEaseOut], animations: {
                    savedLabel.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.2)
                }, completion: { (success) in
                    
                    UIView.animate(withDuration: 0.5, delay: 0.5, options: [.curveEaseIn], animations: {
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                    } , completion: { (success) in
                        savedLabel.removeFromSuperview()
                    })
                })
                
                

                
            }
            Logger.LogDebug(type: .info, message: "Success save photo")
        }
        
        
    }
    
    // MARK: -
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(self.previewPhotoView)
        self.previewPhotoView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(self.cancelButton)
        self.cancelButton.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        
        addSubview(self.saveButton)
        self.saveButton.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 12, paddingRight: 0, width: 50, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}


