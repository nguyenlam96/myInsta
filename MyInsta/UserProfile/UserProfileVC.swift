//
//  UserProfileController.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/2/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import Firebase

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Properties:
    var isGridView = true
    var user: User? {
        didSet {
            if user != nil {
                Logger.LogDebug(type: .info, message: (user?.username)!)
            }
            
        }
    }
    let cellId = "cellId"
    let homePostCellId = "homePostCellId"
    let headerId = "headerId"
    var posts: [Post] = []
    
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        self.collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        self.collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        setupLogoutButton()
        self.fetchUser()
        self.fetchOrderedPosts()
    }
    
    deinit {
        print("=== UserProfileVC is deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    // MARK: - Setup When ViewDidLoad:
    private func setupLogoutButton() {
        if self.user == nil {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(handleLogout))
        }
    }
    
    @objc func handleLogout() {
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { [unowned self](action) in
            
            do {
                try Auth.auth().signOut()
                Logger.LogDebug(type: .info, message: "Do Logout")
                let loginVC = LoginVC()
                let navVC = UINavigationController(rootViewController: loginVC)
                self.present(navVC, animated: true, completion: nil)
            } catch let error {
                Logger.LogDebug(type: .error, message: error.localizedDescription)
                return
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            return
        }
        
        ac.addAction(logoutAction)
        ac.addAction(cancelAction)
        self.present(ac, animated: true)
    }
    
    // MARK: - Setup Header For CollectionView :
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! UserProfileHeader
        
        headerView.user = self.user
        headerView.delegate = self
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 200)
        
    }
    
    // MARK: - UICollectionView Datasource :
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
                cell.post = self.posts[indexPath.item]
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
                cell.post = self.posts[indexPath.item]
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView { // gridview:
            
            let cellWidth = (self.view.frame.width - 2) / 3
            return CGSize(width: cellWidth, height: cellWidth)
        } else { // listview:
            
            var height: CGFloat = 40 + 8 + 8 // for username + userProfileImage ( 40 is the size of image, 8 padding top and 8 padding bottom )
            height += view.frame.width
            height += 50 // for the bottom row of the image
            height += 60 // for the caption
            return CGSize(width: view.frame.width, height: height)
        }
        
    }
    
    // MARK: - Private Funcs :

    private func fetchUser() {
        
        if let _ = self.user?.uid {
            Logger.LogDebug(type: .info, message: "search uid")
        } else if let _ = Auth.auth().currentUser?.uid {
            Logger.LogDebug(type: .info, message: "current uid")
        }
        
            let uid = self.user?.uid ?? Auth.auth().currentUser?.uid ?? ""
        
            databaseRef.child("users").child(uid).observeSingleEvent(of: DataEventType.value, with: { [unowned self](snapshot) in
                
                guard let userInfoDict = snapshot.value as? [String:Any] else {
                    Logger.LogDebug(type: .error, message: "Can't parse snapshot.value ")
                    return
                }
                
                self.user = User(uid: uid, dictionary: userInfoDict)
                self.navigationItem.title = self.user?.username ?? "DefaulName"
                
                self.collectionView.reloadData()
                
            }) { (error) in
                Logger.LogDebug(type: .error, message: error.localizedDescription)
                return
            }
    }
    
    private func fetchOrderedPosts() {
        
        if let _ = self.user?.uid {
            Logger.LogDebug(type: .info, message: "search uid")
        } else if let _ = Auth.auth().currentUser?.uid {
            Logger.LogDebug(type: .info, message: "current uid")
        }
        
        let uid = self.user?.uid ?? Auth.auth().currentUser?.uid ?? ""
        databaseRef.child("posts").child(uid).queryOrdered(byChild: "createdTime").observe(DataEventType.childAdded, with: { [unowned self](snapshot) in
            
            guard let postDict = snapshot.value as? [String:Any] else {
                Logger.LogDebug(type: .error, message: "Can't cast snapshot.value to String:Any")
                return
            }
            
            let postId = snapshot.key
            
            guard let user = self.user else { /// Attempted to read an unowned reference but the object was already deallocated2019-02-27 00:04:31.915516+0700 MyInsta[29567:8219404] Fatal error: Attempted to read an unowned reference but the object was already deallocated
                Logger.LogDebug(type: .error, message: "user doesn't exist")
                return
            }
            var post = Post(dictionary: postDict, by: user)
                post.postId = postId
            self.isPostLiked(postId: postId, completion: { [unowned self](isLiked) in
                
                post.isLiked = (isLiked != nil) ? isLiked : false
                self.posts.insert(post, at: 0)
                self.collectionView.reloadData()
            })
            
            
        }) { (error) in
            Logger.LogDebug(type: .error, message: error.localizedDescription)
            return
        }
    }
    
    private func isPostLiked(postId: String, completion: @escaping (Bool?) -> () ) {
        Logger.LogDebug(type: .info, message: "\(#function) get called")
        
        let uid = Auth.auth().currentUser?.uid
        databaseRef.child("likes").child(postId).child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let value = snapshot.value as? Int else {
                completion(nil)
                return
            }
            let isLiked = (value == 1)
            
            completion(isLiked)
            
        }) { (error) in
            Logger.LogDebug(type: .error, message: error.localizedDescription)
            return
        }
        
    }
    

}

extension UserProfileVC: UserProfileHeaderDelegate {
    
    func didChooseGridView() {
        Logger.LogDebug(type: .info, message: "\(#function) get called")
        self.isGridView = true
        self.collectionView.reloadData()
    }
    
    func didChooseListView() {
        Logger.LogDebug(type: .info, message: "\(#function) get called")
        self.isGridView = false
        self.collectionView.reloadData()
    }
    
}
