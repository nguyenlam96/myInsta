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
        self.setupNavigationItem()
        self.collectionView.backgroundColor = .white
        self.collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: self.cellId)
        
        self.setupNotificationObserve()
        self.setupRefreshControl()
        self.fetchPostsByCurrentUser()
        self.fetchPostsByFollowingUsers()
        
    }
    
    deinit {
        print("=== HomeVC is deinit")
    }
    
    // MARK: -
    private func setupNavigationTitle() {
        let logoView = UIImageView(image: #imageLiteral(resourceName: "text_logo"))
        logoView.contentMode = .scaleAspectFit
        /// because this HomeVC belong to a NavigationController, navigationItem property is used to modify the display of UINavigationBar of this VC in parent's navigation bar:
        self.navigationItem.titleView = logoView
    }
    private func setupNavigationItem() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
    }
    
    @objc func handleCamera() {
        let cameraController = CameraController()
        self.present(cameraController, animated: true, completion: nil)
    }
    
    private func setupNotificationObserve() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateNewPostNotification), name: CustomNotification.UpdateNewPost, object: nil)
    }
    
    @objc func handleUpdateNewPostNotification() {
        Logger.LogDebug(type: .info, message: "\(#function)")
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
    
    
    
    
    // MARK: -
    private func fetchPostsByCurrentUser() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            Logger.LogDebug(type: .error, message: "current uid is nil")
            return
        }
        
        databaseRef.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // fetch user:
            guard let userDict = snapshot.value as? [String:Any] else {
                Logger.LogDebug(type: .error, message: "userDict is empty")
                return
            }
            let user = User(uid: uid, dictionary: userDict)
            
            // fetch post:
            self.fetchPostWithUser(user: user)
            
        }) { (error) in
            Logger.LogDebug(type: .error, message: error.localizedDescription)
            return
        }
        
        
    }
    
    private func fetchPostsByFollowingUsers() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else {
            return
        }
        databaseRef.child("following").child(currentUid).observeSingleEvent(of: .value, with: { [unowned self](snapshot) in
            
            guard let followingUserIds = snapshot.value as? [String:Any] else {
                Logger.LogDebug(type: .error, message: "Something wrong")
                return
            }
            for (key, _) in followingUserIds {
                
                databaseRef.child("users").child(key).observeSingleEvent(of: .value, with: { [unowned self](snapshot) in
                    if let userDict = snapshot.value as? [String:Any] {
                        let user = User(uid: key, dictionary: userDict)
                        self.fetchPostWithUser(user: user)
                    } else {
                        Logger.LogDebug(type: .info, message: "This user doesn't existed")
                    }
                    }, withCancel: { (error) in
                        Logger.LogDebug(type: .error, message: error.localizedDescription)
                        return
                })
                
            }
            
        }) { (error) in
            Logger.LogDebug(type: .error, message: error.localizedDescription)
            return
        }
    }
    
    private func fetchPostWithUser(user: User) {
        // fetch post:
        databaseRef.child("posts").child(user.uid).observeSingleEvent(of: DataEventType.value, with: { [unowned self](snapshot) in
            
            /// stop refresh controller after getting value
            self.collectionView.refreshControl?.endRefreshing()
            /// get all posts by currentUser:
            guard let postDicts = snapshot.value as? [String:Any] else {
                return
            }
            postDicts.forEach({ [unowned self](key, value) in
                guard let singlePostDict = value as? [String:Any] else {
                    Logger.LogDebug(type: .error, message: "Can't fetch single post")
                    return
                }
                var post = Post(dictionary: singlePostDict, by: user)
                    post.postId = key
                
                self.isPostLiked(postId: key, completion: { [unowned self](isLiked) in
                    
                    post.isLiked = (isLiked != nil) ? isLiked : false
                    self.posts.append(post)
                    self.posts.sort(by: { (post1, post2) -> Bool in
                        return post1.createdTime.compare(post2.createdTime) == .orderedDescending
                    })
                    
                    self.collectionView.reloadData()
                })
                
                
            }) // end loop
            
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
    
    // MARK: - CollectionView Datasource :
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! HomePostCell
        if indexPath.item < self.posts.count {
            cell.post = self.posts[indexPath.item]
            cell.delegate = self
        }
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

extension HomeVC: HomePostCellDelegate {
    
    func didTapCommentButton(post: Post) {
        
        Logger.LogDebug(type: .info, message: "goto comment section of post: \(post.caption)")
        let commentVC = CommentVC(collectionViewLayout: UICollectionViewFlowLayout() )
            commentVC.post = post
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func didLikePost(cell: UICollectionViewCell) {
        Logger.LogDebug(type: .info, message: "\(#function) get called")
        guard let indexPath = self.collectionView.indexPath(for: cell) else {
            Logger.LogDebug(type: .error, message: "indexPath is nil")
            return
        }
        var post = self.posts[indexPath.row]
        
        guard let postId = post.postId else {
            Logger.LogDebug(type: .error, message: "postId is nil")
            return
        }
        let uid = Auth.auth().currentUser?.uid
        let values = [uid : post.isLiked! ? 0 : 1]
        databaseRef.child("likes").child(postId).setValue(values) { (error, ref) in
            
            guard error == nil else {
                return
            }
            
            post.isLiked = !post.isLiked!
            self.posts[indexPath.row] = post
            self.collectionView.reloadItems(at: [indexPath])
        }
        
        
    }
    
}
