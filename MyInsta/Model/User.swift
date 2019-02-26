//
//  User.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/2/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation

struct User {
    
    let uid: String
    let username: String
    let profileImageStringUrl: String
    
    init(uid: String, dictionary: [String:Any]) {
        self.uid = uid
        self.username = (dictionary["username"] as? String) ?? ""
        self.profileImageStringUrl = (dictionary["profileImageUrl"] as? String) ?? ""
    }
    
}
