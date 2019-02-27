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
    
    // MARK: -
    let cellId = "cellId"
    var posts = [Post]()
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationTitle()
        self.collectionView.backgroundColor = .white
        self.collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: self.cellId)
        
        self.setupNotificationObserve()
        self.setupRefreshControl()
        self.fetchPostsByCurrentUser()
        self.fetchPostsByFollowingUsers()
        
    }
    
    
    // MARK: -
    
    private func setupNotificationObserve() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateNewPostNotification), name: CustomNotification.UpdateNewPost, object: nil)
    }
    
    @objc func handleUpdateNewPostNotification() {
        LogUtils.LogDebug(type: .info, message: "\(#function)")
        self.handleRefresh()
    }
    
    private func setupRefreshControl() {
        
        let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
        self.collectionView.refreshControl = refreshControl
        
    }
    
    
    @objc func handleRefresh() {
        print("handle refresh")
        self.posts.removeAll()
        self.fetchPostsByCurrentUser()
        self.fetchPostsByFollowingUsers()
    }
    
    private func fetchPostsByFollowingUsers() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else {
            return
        }
        databaseRef.child("following").child(currentUid).observeSingleEvent(of: .value, with: { [unowned self](snapshot) in
            
            guard let followingUserIds = snapshot.value as? [String:Any] else {
                LogUtils.LogDebug(type: .error, message: "Something wrong")
                return
            }
            for (key, _) in followingUserIds {
                
                databaseRef.child("users").child(key).observeSingleEvent(of: .value, with: { [unowned self](snapshot) in
                    if let userDict = snapshot.value as? [String:Any] {
                        let user = User(uid: key, dictionary: userDict)
                        self.fetchPostWithUser(user: user)
                    } else {
                        LogUtils.LogDebug(type: .info, message: "This user doesn't existed")
                    }
                }, withCancel: { (error) in
                    LogUtils.LogDebug(type: .error, message: error.localizedDescription)
                    return
                })
                
            }
            
        }) { (error) in
            LogUtils.LogDebug(type: .error, message: error.localizedDescription)
            return
        }
    }
    
    private func setupNavigationTitle() {
        let logoView = UIImageView(image: #imageLiteral(resourceName: "text_logo"))
            logoView.contentMode = .scaleAspectFit
        /// because this HomeVC belong to a NavigationController, navigationItem property is used to modify the display of UINavigationBar of this VC in parent's navigation bar:
        self.navigationItem.titleView = logoView
    }
    
    
    // MARK: -
    private func fetchPostsByCurrentUser() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            LogUtils.LogDebug(type: .error, message: "current uid is nil")
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
            self.fetchPostWithUser(user: user)
            
        }) { (error) in
            LogUtils.LogDebug(type: .error, message: error.localizedDescription)
            return
        }
        
        
    }
    
    private func fetchPostWithUser(user: User) {
        // fetch post:
        let uid = user.uid
        databaseRef.child("posts").child(uid).observeSingleEvent(of: DataEventType.value, with: { [unowned self](snapshot) in
            
            /// stop refresh controller after getting value
            self.collectionView.refreshControl?.endRefreshing()
            /// get all posts by currentUser:
            guard let postDicts = snapshot.value as? [String:Any] else {
                LogUtils.LogDebug(type: .error, message: "Can't cast snapshot.value to String:Any")
                return
            }
            postDicts.forEach({ [unowned self](key, value) in
                guard let singlePostDict = value as? [String:Any] else {
                    LogUtils.LogDebug(type: .error, message: "Can't fetch single post")
                    return
                }
                let post = Post(dictionary: singlePostDict, by: user)
                self.posts.append(post)
            }) // end loop
            
            self.posts.sort(by: { (post1, post2) -> Bool in
                return post1.createdTime.compare(post2.createdTime) == .orderedDescending
            })
            
            self.collectionView.reloadData()
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
