//
//  UserProfilePhotoCell.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/8/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit

class UserProfilePhotoCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            // load image task:
            guard let imageUrl = post?.imageUrl else {
                LogUtils.LogDebug(type: .error, message: "imageUrl is nil")
                return
            }
            self.photoImageView.fetchPostImage(with: imageUrl)
        }
    }
    let photoImageView: CustomImageView = {
       
        let iv = CustomImageView()
            iv.backgroundColor = UIColor.lightGray
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
}
