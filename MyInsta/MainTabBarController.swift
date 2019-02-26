//
//  MainTabBarController.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/2/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Firebase
import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = self.viewControllers?.index(of: viewController)
        if index == 2 {
            
            let photoSelectorVC = PhotoSelectorVC(collectionViewLayout: UICollectionViewFlowLayout() )
            let navController = UINavigationController(rootViewController: photoSelectorVC)
            
            self.present(navController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        if Auth.auth().currentUser == nil {
            // no user, present LoginVC
            DispatchQueue.main.async {
                let loginVC = LoginVC()
                let navVC = UINavigationController(rootViewController: loginVC)
                self.present(navVC, animated: true, completion: nil)
            }
            return
        } else {
            
            self.setupVC()
            
        }
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.selectedIndex = 1 // this selectedIndex belong to UITabBarController, change it to set defaul tabbar
        ///        self.tabBarController?.selectedIndex = 4  --> this tabBarController property is the nearest ancester UITabBarController of this viewController ( will be nil because this VC doesn't have any super UITabBarController )
    }
    
    func setupVC() {
        // home:
        let homeNavController = templateNavController(image: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootVC: HomeVC(collectionViewLayout: UICollectionViewFlowLayout()) )
        // search:
        let searchNavController = templateNavController(image: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootVC: UserSearchVC(collectionViewLayout: UICollectionViewFlowLayout() ))
        // plus:
        let plusNavController = templateNavController(image: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
        // heart:
        let likeNavController = templateNavController(image: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"))
        // profile:
        let userProfileNavController = templateNavController(image: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootVC:  UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout() ))

        self.tabBar.tintColor = .black
        self.viewControllers = [homeNavController, searchNavController, plusNavController, likeNavController, userProfileNavController]
        guard let items = tabBar.items else {
            LogUtils.LogDebug(type: .error, message: "Tabbar has no item")
            return
        }
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
    
    private func templateNavController(image: UIImage, selectedImage: UIImage, rootVC: UIViewController = UIViewController() ) -> UINavigationController {

//        let viewController = rootVC
        let navController = UINavigationController(rootViewController: rootVC)
        
        navController.tabBarItem.image = image
        navController.tabBarItem.selectedImage = selectedImage
        
        return navController
        
    }
    
}

