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
        self.inputTextField.becomeFirstResponder()
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
    
    
    var inputTextField: UITextField = {
       let inputTextField = UITextField()
           inputTextField.placeholder = "enter comment"
        
        return inputTextField
    }()
    
    lazy var containerView: UIView = {

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 50))
            containerView.backgroundColor = .white

        let sendButton = UIButton(type: UIButton.ButtonType.system)
            sendButton.setTitle("Send", for: .normal)
            sendButton.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: UIControl.State.normal)
            sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.addTarget(self, action: #selector(handleSendButton), for: UIControl.Event.touchUpInside)
        
        let lineSeperator = UIView()
            lineSeperator.backgroundColor = UIColor.rgb(r: 230, g: 230, b: 230)

        containerView.addSubview(inputTextField)
        containerView.addSubview(sendButton)
        containerView.addSubview(lineSeperator)
        
        self.inputTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)

        sendButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 0)

        lineSeperator.anchor(top: self.inputTextField.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    
    // MARK: -
    @objc func handleSendButton() {
        Logger.LogDebug(type: .info, message: "\(#function)")
        
        guard let post = self.post else {
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let values = [ "text": self.inputTextField.text ?? "",
                       "creationTime" : Date().timeIntervalSince1970,
                       "uid": uid] as [String:Any]
        
        databaseRef.child("comments").child(post.postId!).childByAutoId().updateChildValues(values) { (error, ref) in
            
            guard error == nil else {
                Logger.LogDebug(type: .error, message: error!.localizedDescription)
                return
            }
            Logger.LogDebug(type: .info, message: "Save comment success")
        }
        self.inputTextField.text = ""
        self.inputTextField.resignFirstResponder()
        
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
