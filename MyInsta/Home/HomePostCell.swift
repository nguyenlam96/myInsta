//
//  HomePostCell.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/12/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit

protocol HomePostCellDelegate: class {
    
    func didTapCommentButton(post: Post)
    func didLikePost(cell: UICollectionViewCell)
}

class HomePostCell: UICollectionViewCell {
    
    // MARK: - Properties:
    
    weak var delegate: HomePostCellDelegate?
    
    var post: Post? {
        didSet {
            // user profile image:
            guard let profileImageUrl = post?.user.profileImageStringUrl else {
                Logger.LogDebug(type: .error, message: "profileImageUrl is nil")
                return
            }
            self.userProfileImageView.fetchPostImage(with: profileImageUrl)
            
            // liked or not:
            guard let isLiked = post?.isLiked else {
                Logger.LogDebug(type: .error, message: "isLiked is nil")
                return
            }
            self.likeButton.setImage(isLiked ? #imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal) , for: .normal)
            
            // username label:
            guard let username = post?.user.username else {
                Logger.LogDebug(type: .error, message: "username is nil")
                return
            }
            self.usernameLabel.text = username
            
            // post image:
            guard let imageUrl = post?.imageUrl else {
                Logger.LogDebug(type: .error, message: "imageUrl is nil")
                return
            }
            self.photoImageView.fetchPostImage(with: imageUrl)
            
            // caption:
            setupAttributedCaption()
        }
    }
    
    fileprivate func setupAttributedCaption() {
        guard let post = self.post else {
            Logger.LogDebug(type: .error, message: "post is nil")
            return
        }
        let attributedText = NSMutableAttributedString(string: post.user.username + " ", attributes: [.font : UIFont.boldSystemFont(ofSize: 14)] )
        attributedText.append(NSAttributedString(string: post.caption, attributes: [.font: UIFont.systemFont(ofSize: 14)] ) )
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [.font: UIFont.systemFont(ofSize: 4)] ))
        let timeAgoDisplay = post.createdTime.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: timeAgoDisplay, attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                    .foregroundColor: UIColor.gray] ) )
        self.captionLabel.attributedText = attributedText
    }
    // MARK: - Create UI :
    let userProfileImageView: CustomImageView = {
       let  iv = CustomImageView()
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.backgroundColor = .blue
        return iv
    }()
    
    let photoImageView: CustomImageView = {
       let iv = CustomImageView()
           iv.backgroundColor = .white
           iv.contentMode = .scaleAspectFill
           iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
            label.text = "Username"
            label.font = UIFont.boldSystemFont(ofSize: 14)
        
        return label
    }()
    
    let optionsButton: UIButton = {
       let button = UIButton(type: .system)
            button.setTitle("•••", for: .normal)
            button.setTitleColor(.black, for: .normal)
        return button
    }()

    lazy var likeButton: UIButton = {
        let button = UIButton()
            button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
            button.addTarget(self, action: #selector(handleLikeButton), for: .touchUpInside)
        return button
    }()
    
    @objc func handleLikeButton() {
        
        delegate?.didLikePost(cell: self)
    }
    
    lazy var commentButton: UIButton = {
        let button = UIButton()
            button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCommentButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func handleCommentButtonTapped() {
        guard let post = self.post else {
            Logger.LogDebug(type: .error, message: "Current Post is empty")
            return
        }
        delegate?.didTapCommentButton(post: post)
    }
    
    let sendMessageButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
        
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        
        return button
    }()
    
    let captionLabel: UILabel = {
       let label = UILabel()
           label.numberOfLines = 0

        return label
    }()
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.setupView()
        self.setupActionButtons()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup When ViewDidLoad:
    private func setupView() {
        
        self.addSubview(userProfileImageView)
        self.addSubview(usernameLabel)
        self.addSubview(optionsButton)
        self.addSubview(photoImageView)
        // photo image
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        userProfileImageView.layer.cornerRadius = 40 / 2
        // username label
        usernameLabel.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: photoImageView.topAnchor, right: optionsButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        // options button
        optionsButton.anchor(top: topAnchor, left: nil, bottom: photoImageView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 44, height: 0)
        // photo iamge
        photoImageView.anchor(top: userProfileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        photoImageView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1).isActive = true
    }
    
    private func setupActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, sendMessageButton])
            stackView.distribution = .fillEqually
            stackView.axis = .horizontal
        
        self.addSubview(stackView)
        stackView.anchor(top: photoImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        
        self.addSubview(bookmarkButton)
        bookmarkButton.anchor(top: photoImageView.bottomAnchor, left: nil, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 50)
        
        self.addSubview(captionLabel)
        captionLabel.anchor(top: likeButton.bottomAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    }
    
    
}
