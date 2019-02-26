//
//  HomeVC.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/6/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import Firebase


class HomeVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties:
    let cellId = "cellId"
    var posts = [Post]()
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationTitle()
        self.collectionView.backgroundColor = .white
        self.collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: self.cellId)
        self.fetchPosts()
    }
    
    // MARK: - Setup When ViewDidLoad:
    private func setupNavigationTitle() {
        let logoView = UIImageView(image: #imageLiteral(resourceName: "text_logo"))
            logoView.contentMode = .scaleAspectFit
        /// because this HomeVC belong to a NavigationController, navigationItem property is used to modify the display of UINavigationBar of this VC in parent's navigation bar:
        self.navigationItem.titleView = logoView
    }
    
    
    // MARK: - Network funcs:
    private func fetchPosts() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            LogUtils.LogDebug(type: .error, message: "uid is nil")
            return
        }
        
        databaseRef.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // fetch user:
            guard let userDict = snapshot.value as? [String:Any] else {
                LogUtils.LogDebug(type: .error, message: "userDict is empty")
                return
            }
            let user = User(uid: uid, dictionary: userDict)
            
            // fetch post:
            databaseRef.child("posts").child(uid).observeSingleEvent(of: DataEventType.value, with: { [unowned self](snapshot) in
                // get all posts by currentUser:
                guard let postsDict = snapshot.value as? [String:Any] else {
                    LogUtils.LogDebug(type: .error, message: "Can't cast snapshot.value to String:Any")
                    return
                }
                // loop through each post:
                postsDict.forEach({ [unowned self](key, value) in
                    // handle single post:
                    guard let singlePostDict = value as? [String:Any] else {
                        LogUtils.LogDebug(type: .error, message: "Can't fetch single post")
                        return
                    }
//                    let dummyUser = User(dictionary: ["username":"NguyenLam"])
                    let post = Post(dictionary: singlePostDict, by: user)
                    self.posts.append(post)
                }) // end loop
                self.collectionView.reloadData()
            }) { (error) in
                LogUtils.LogDebug(type: .error, message: error.localizedDescription)
                return
            }
            
        }) { (error) in
            LogUtils.LogDebug(type: .error, message: error.localizedDescription)
            return
        }
        
        
    }
    
    
    // MARK: - CollectionView Datasource :
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! HomePostCell
            cell.post = self.posts[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8 // for username + userProfileImage ( 40 is the size of image, 8 padding top and 8 padding bottom )
            height += view.frame.width
            height += 50 // for the bottom row of the image
            height += 60 // for the caption
        return CGSize(width: view.frame.width, height: height)
    }
    
}
