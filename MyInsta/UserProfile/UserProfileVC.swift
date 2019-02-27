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
    var user: User? {
        didSet {
            if user != nil {
                LogUtils.LogDebug(type: .info, message: (user?.username)!)
            }
            
        }
    }
    let cellId = "cellId"
    let headerId = "headerId"
    var posts: [Post] = []
    
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        self.collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
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
                LogUtils.LogDebug(type: .info, message: "Do Logout")
                let loginVC = LoginVC()
                let navVC = UINavigationController(rootViewController: loginVC)
                self.present(navVC, animated: true, completion: nil)
            } catch let error {
                LogUtils.LogDebug(type: .error, message: error.localizedDescription)
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            cell.post = self.posts[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = (self.view.frame.width - 2) / 3
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    // MARK: - Private Funcs :

    private func fetchUser() {
        
        if let _ = self.user?.uid {
            LogUtils.LogDebug(type: .info, message: "search uid")
        } else if let _ = Auth.auth().currentUser?.uid {
            LogUtils.LogDebug(type: .info, message: "current uid")
        }
        
            let uid = self.user?.uid ?? Auth.auth().currentUser?.uid ?? ""
        
            databaseRef.child("users").child(uid).observeSingleEvent(of: DataEventType.value, with: { [unowned self](snapshot) in
                
                guard let userInfoDict = snapshot.value as? [String:Any] else {
                    LogUtils.LogDebug(type: .error, message: "Can't parse snapshot.value ")
                    return
                }
                
                self.user = User(uid: uid, dictionary: userInfoDict)
                self.navigationItem.title = self.user?.username ?? "DefaulName"
                
                self.collectionView.reloadData()
                
            }) { (error) in
                LogUtils.LogDebug(type: .error, message: error.localizedDescription)
                return
            }
    }
    
    private func fetchOrderedPosts() {
        
        if let _ = self.user?.uid {
            LogUtils.LogDebug(type: .info, message: "search uid")
        } else if let _ = Auth.auth().currentUser?.uid {
            LogUtils.LogDebug(type: .info, message: "current uid")
        }
        
        let uid = self.user?.uid ?? Auth.auth().currentUser?.uid ?? ""
        databaseRef.child("posts").child(uid).queryOrdered(byChild: "createdTime").observe(DataEventType.childAdded, with: { [unowned self](snapshot) in
            
            guard let postsDict = snapshot.value as? [String:Any] else {
                LogUtils.LogDebug(type: .error, message: "Can't cast snapshot.value to String:Any")
                return
            }
            guard let user = self.user else { /// Attempted to read an unowned reference but the object was already deallocated2019-02-27 00:04:31.915516+0700 MyInsta[29567:8219404] Fatal error: Attempted to read an unowned reference but the object was already deallocated
                LogUtils.LogDebug(type: .error, message: "user doesn't exist")
                return
            }
            let post = Post(dictionary: postsDict, by: user)
            self.posts.insert(post, at: 0)
            self.collectionView.reloadData()
        }) { (error) in
            LogUtils.LogDebug(type: .error, message: error.localizedDescription)
            return
        }
    }
    

}
