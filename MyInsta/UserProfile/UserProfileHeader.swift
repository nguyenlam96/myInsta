//
//  UserProfileHeader.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/2/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Firebase
import UIKit

protocol UserProfileHeaderDelegate: class {
    
    func didChooseGridView()
    func didChooseListView()
}

class UserProfileHeader: UICollectionViewCell {
    // MARK: -
    var isGridView = true
    weak  var delegate: UserProfileHeaderDelegate?
    var isFollowing: Bool? {
        didSet {
            updateUIOfFollowButton()
        }
    }
    var user: User? {
        
        didSet {
            // ensure user is not nil
            guard let user = user else {
                Logger.LogDebug(type: .error, message: "user is nil")
                return
            }
            // check if currentUser OR searchedUser:
            let currentUid = Auth.auth().currentUser?.uid
            if user.uid != currentUid { // not current user
                self.editProfileButton.isHidden = true
                self.followButton.isHidden = false
            } else { // current user
                self.followButton.isHidden = true
                self.editProfileButton.isHidden = false
            }
            // check if is following OR not
            databaseRef.child("following").child(currentUid!).child(user.uid).observeSingleEvent(of: .value, with: { [unowned self](snapshot) in
                
                if let following = snapshot.value as? Int, following == 1 {
                    self.isFollowing = true
                } else {
                    self.isFollowing = false
                }
                
            }) { (error) in
                Logger.LogDebug(type: .error, message: "")
            }
            // load image:
            self.loadProfileImage()
            self.usernameLabel.text = user.username
            
        }
    }
    
    private func updateUIOfFollowButton() {
        if self.isFollowing == true {
            // unfollow button
            self.followButton.setTitle("Unfollow", for: .normal)
            self.followButton.setTitleColor(.black, for: .normal)
            self.followButton.backgroundColor = UIColor.white
            self.followButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            //        button.setTitleColor(.black, for: .normal)
            self.followButton.layer.borderColor = UIColor.lightGray.cgColor
        } else {
            // follow button
            self.followButton.setTitle("Follow", for: .normal)
            self.followButton.setTitleColor(.white, for: .normal)
            self.followButton.backgroundColor = UIColor.rgb(r: 17, g: 154, b: 273)
            self.followButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            self.followButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        }
    }
    
    // MARK: -
    
    // profile image
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(white: 0, alpha: 0.03)
        imageView.layer.cornerRadius = 80 / 2
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    // username label
    let usernameLabel: UILabel = {
        
        let label = UILabel()
            label.text = ""
            label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    // state:
    let postLabel: UILabel = {
        
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray,
                                                                                   NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]))
  
        let label = UILabel()
            label.attributedText = attributedText
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 12)
            label.textAlignment = .center
        return label
    }()
    
    let followerLabel: UILabel = {
        
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "follower", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray,
                                                                               NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]))
        
        let label = UILabel()
            label.attributedText = attributedText
            label.font = UIFont.systemFont(ofSize: 12)
            label.numberOfLines = 0
            label.textAlignment = .center
        return label
    }()
    
    let followingLabel: UILabel = {
        
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray,
                                                                               NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]))
        
        let label = UILabel()
            label.attributedText = attributedText
            label.font = UIFont.systemFont(ofSize: 12)
            label.numberOfLines = 0
            label.textAlignment = .center
        
        return label
    }()
    
    // edit profile button
    lazy var editProfileButton: UIButton = {
        
        let button = UIButton(type: UIButton.ButtonType.system)
            button.setTitle("Edit Profile", for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            button.setTitleColor(.black, for: .normal)
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditButtonPressed), for: .touchUpInside)
        return button
    }()
    lazy var followButton: UIButton = {
        
        let button = UIButton(type: UIButton.ButtonType.system)
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 3
            button.addTarget(self, action: #selector(handleFollowButtonPressed), for: .touchUpInside)
        return button
    }()
    // bottom tool bar:
    lazy var gridButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
            button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        button.addTarget(self, action: #selector(handleGridButton), for: .touchUpInside)
       return button
    }()
    
    @objc func handleGridButton() {
        self.isGridView = true
        self.gridButton.tintColor = UIColor.mainBlue()
        self.listButton.tintColor = UIColor.whiteGray()
        delegate?.didChooseGridView()
    }
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
            button.tintColor = UIColor(white: 0, alpha: 0.5)
            button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
            button.addTarget(self, action: #selector(handleListButton), for: .touchUpInside)
        return button
    }()
    
    @objc func handleListButton() {
        self.isGridView = false
        self.gridButton.tintColor = UIColor.whiteGray()
        self.listButton.tintColor = UIColor.mainBlue()
        delegate?.didChooseListView()
    }
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
            button.tintColor = UIColor(white: 0, alpha: 0.5)
            button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        return button
    }()
    
    // MARK: -
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupProfileImage()
        self.setupBottomToolBar()
        self.setupUsernameLabel()
        self.setupStateView()
        self.setupEditProfileButton()
        self.setupFollowButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init(coder:) has not been implemented")
    }
    
    // MARK: -
    private func setupProfileImage() {
        
        self.addSubview(profileImageView)
        self.profileImageView.anchor(top: topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
    }
    
    private func setupUsernameLabel() {
        
        self.addSubview(usernameLabel)
        
        self.usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)

    }
    
    private func setupStateView() {
        
        let stackView = UIStackView(arrangedSubviews: [postLabel, followerLabel, followingLabel])
            stackView.distribution = .fillEqually
            stackView.axis = .horizontal
        self.addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }
    
    private func setupBottomToolBar() {
        
        let topDividerView = UIView()
            topDividerView.backgroundColor = UIColor.lightGray
        
        let bottomDividerView = UIView()
            bottomDividerView.backgroundColor = UIColor.lightGray
        
        let stackView = UIStackView(arrangedSubviews: [self.gridButton, self.listButton, self.bookmarkButton])
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
        
        self.addSubview(stackView)
        self.addSubview(topDividerView)
        self.addSubview(bottomDividerView)
        
        stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
    }
    
    private func setupEditProfileButton() {
        
        self.addSubview(editProfileButton)
        self.editProfileButton.frame = CGRect(x: postLabel.frame.origin.x, y: 0, width: 0, height: 34)
        self.editProfileButton.anchor(top: postLabel.bottomAnchor, left: postLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
    }
    private func setupFollowButton() {
        
        self.addSubview(followButton)
        self.followButton.frame = CGRect(x: postLabel.frame.origin.x, y: 0, width: 0, height: 34)
        self.followButton.anchor(top: postLabel.bottomAnchor, left: postLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
    }
    // MARK: -
    private func loadProfileImage() {
        
        guard let urlString = self.user?.profileImageStringUrl else {
            Logger.LogDebug(type: .error, message: "urlString is nil")
            return
        }
        guard let profileImageUrl = URL(string: urlString) else {
            Logger.LogDebug(type: .error, message: "url is not valid")
            return
        }

        URLSession.shared.dataTask(with: profileImageUrl ) { [unowned self](data, response, error) in
            
            guard error == nil else {
                Logger.LogDebug(type: .error, message: error!.localizedDescription)
                return
            }
            // check response value == 200 HTTP
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    Logger.LogDebug(type: .error, message: "Status code: \(httpResponse.statusCode)")
                }
            } else {
                Logger.LogDebug(type: .error, message: "response is nil")
            }
            
            if profileImageUrl.absoluteString != self.user?.profileImageStringUrl {
                return
            }
            
            // check data:
            guard let data = data else {
                Logger.LogDebug(type: .error, message: "data is nil")
                return
            }
            
            DispatchQueue.main.async {
                let profileImage = UIImage(data: data)
                self.profileImageView.image = profileImage
            }
            
        }.resume()
 
    }
    
    @objc private func handleEditButtonPressed() {
        Logger.LogDebug(type: .info, message: "\(#function)")
    }
    
    @objc private func handleFollowButtonPressed() {
        
        Logger.LogDebug(type: .info, message: "\(#function)")
        
        guard let currentLoggedUserId = Auth.auth().currentUser?.uid else {
            Logger.LogDebug(type: .info, message: "currentUid is nil")
            return
        }
        guard let uid = self.user?.uid else {
            Logger.LogDebug(type: .info, message: "searchedUser uid is nil")
            return
        }
        
        let value = [ uid:1 ]
        
        if self.isFollowing == false {
            // do follow:
            databaseRef.child("following").child(currentLoggedUserId).updateChildValues(value) { [unowned self](error, ref) in
                
                if let error = error {
                    Logger.LogDebug(type: .error, message: error.localizedDescription)
                    return
                }
                self.isFollowing = true
                Logger.LogDebug(type: .info, message: "Successfully follow the user: \(String(describing: self.user?.username))" )
                
                
            }
        } else {
            // delete follow
            databaseRef.child("following").child(currentLoggedUserId).child((self.user?.uid)!).removeValue { [unowned self](error, ref) in
                if let error = error {
                    Logger.LogDebug(type: .error, message: error.localizedDescription)
                    return
                }
                self.isFollowing = false
                Logger.LogDebug(type: .info, message: "Successfully unfollow the user: \(String(describing: self.user?.username))")
            }
        }
        
        
    }
    
    
    
}
