//
//  User.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/2/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation

struct User {
    
    let username: String
    let profileImageStringUrl: String
    
    init(dictionary: [String:Any]) {
        self.username = (dictionary["username"] as? String) ?? ""
        self.profileImageStringUrl = (dictionary["profileImageUrl"] as? String) ?? ""
    }
    
}
