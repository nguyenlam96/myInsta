//
//  PhotoSelectorCell.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/6/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit

class PhotoSelectorCell: UICollectionViewCell {
    
    let photoImageView: UIImageView = {
       
        let imageView = UIImageView()
            imageView.backgroundColor = UIColor.lightGray
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
        return imageView
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
