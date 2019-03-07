//
//  Comment.swift
//  MyInsta
//
//  Created by Nguyen Lam on 3/6/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation

struct Comment {
    
    var user: User
    let uid: String
    let text: String
    let creationTime: Date
    
//    init(uid: String, text: String, creationTime: Date) {
//
//        self.uid = uid
//        self.text = text
//        self.creationTime = creationTime
//    }
//
//    init(from dictionary: [String:Any]) {
//
//        self.uid = dictionary["uid"] as? String ?? ""
//        self.text = dictionary["text"] as? String ?? ""
//
//        let timeInterval = dictionary["creationTime"] as? Double ?? 0
//        self.creationTime = Date(timeIntervalSince1970: timeInterval)
//
//    }
    
    init(user: User, from dictionary: [String:Any]) {
        
        self.user = user
        self.uid = dictionary["uid"] as? String ?? ""
        self.text = dictionary["text"] as? String ?? ""
        
        let timeInterval = dictionary["creationTime"] as? Double ?? 0
        self.creationTime = Date(timeIntervalSince1970: timeInterval)
        
    }
    
}
