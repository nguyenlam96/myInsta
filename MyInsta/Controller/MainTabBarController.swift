//
//  MainTabBarController.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/2/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout() )
        let navController = UINavigationController(rootViewController: userProfileVC)
        
        navController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        navController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        
        self.tabBar.tintColor = UIColor.black
        self.viewControllers = [navController]
        
    }
    
}

