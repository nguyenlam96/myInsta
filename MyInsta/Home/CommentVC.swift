//
//  CommentVC.swift
//  MyInsta
//
//  Created by Nguyen Lam on 3/6/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import Firebase

class CommentVC: UICollectionViewController {

    // MARK: -
    var post: Post?
    var comments: [Comment] = []
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Comments"
        
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.keyboardDismissMode = .interactive
        
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        self.fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.commentInputAccessoryView.showInputTextView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        tabBarController?.tabBar.isHidden = false
    }
    
    deinit {
        print("=== CommentVC is deinit")
    }
    
    // MARK: -
    private func fetchComments() {
        
        guard let post = self.post else {return}
        
        //
        databaseRef.child("comments").child(post.postId!).observe(.childAdded, with: { [unowned self](snapshot) in
            
            guard let commentDict = snapshot.value as?  [String:Any]  else {
                return
            }
            
            guard let uid = commentDict["uid"] as? String else {
                return
            }
            
            self.fetchUserWith(uid: uid, completion: { [unowned self](user) in
                Logger.LogDebug(type: .info, message: "\(#function)")
                let comment = Comment(user: user, from: commentDict)
                self.comments.append(comment)
                self.collectionView.reloadData()
            })
            
        }) { (error) in
            Logger.LogDebug(type: .error, message: error.localizedDescription)
        }
        
    }
    
    private func fetchUserWith(uid: String, completion: @escaping (User) -> () ){
        
        databaseRef.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let userDict = snapshot.value as? [String:Any] else {
                Logger.LogDebug(type: .error, message: "can't get userDict")
                return
            }
            
            let user =  User(uid: uid, dictionary: userDict)
            completion(user)
        }

    }
    
    // MARK: -
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    lazy var commentInputAccessoryView: CommentInputAccessoryView = {

        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        let commentInputAccessoryView = CommentInputAccessoryView(frame: frame)
            commentInputAccessoryView.delegate = self
            commentInputAccessoryView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        
        return commentInputAccessoryView
        
    }()
    
    override var inputAccessoryView: UIView? {
        
        get {
            return commentInputAccessoryView
        }
    }
    
    
}

extension CommentVC: CommentInputAccessoryViewDelegate {
    
    func didSendComment(with content: String) {
        Logger.LogDebug(type: .info, message: "\(#function)")
        
        guard let post = self.post else {
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let values = [ "text": content,
                       "creationTime" : Date().timeIntervalSince1970,
                       "uid": uid] as [String:Any]
        
        databaseRef.child("comments").child(post.postId!).childByAutoId().updateChildValues(values) { [unowned self](error, ref) in
            
            guard error == nil else {
                Logger.LogDebug(type: .error, message: error!.localizedDescription)
                return
            }
            Logger.LogDebug(type: .info, message: "Save comment success")
            self.commentInputAccessoryView.handleInputTextViewAfterSent()
        }
    }
}


extension CommentVC: UICollectionViewDelegateFlowLayout {
    
    // MARK: - CollectionView DataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        let comment = self.comments[indexPath.row]
        cell.comment = comment
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // MARK: - Fit the cell's size to the text length
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
            dummyCell.comment = self.comments[indexPath.row]
            dummyCell.layoutIfNeeded()
        
        let targetSize =  CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40+8+8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
        
    }

    
    
}

