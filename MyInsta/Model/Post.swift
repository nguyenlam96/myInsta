//
//  Post.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/8/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit

struct Post {
    
    var postId: String?
    let user: User
    let caption: String
    let imageUrl: String
    let imageSize: [String:CGFloat]
    let createdTime: Date
    var isLiked: Bool?
    
    init(dictionary: [String:Any], by user: User) {
        self.user = user
        self.imageUrl = (dictionary["imageUrl"] as? String) ?? ""
        self.caption = (dictionary["caption"] as? String) ?? ""
        self.imageSize = (dictionary["imageSize"] as? [String:CGFloat]) ?? ["width": 100, "height": 100]
        
        let timeInterval = dictionary["createdTime"] as? Double ?? 0
        self.createdTime = Date(timeIntervalSince1970: timeInterval)
    }
    
    
}
