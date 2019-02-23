//
//  UserProfileHeader.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/2/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation
import UIKit

class UserProfileHeader: UICollectionViewCell {
    
    // MARK: - Properties:
    var user: User? {
        didSet {
            if user != nil {
                self.loadProfileImage()
                self.usernameLabel.text = user?.username ?? "DefaulName"
            }
        }
    }
    
    // MARK: - Create UI :
    
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
    let editProfileButton: UIButton = {
        
        let button = UIButton(type: UIButton.ButtonType.system)
            button.setTitle("Edit Profile", for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            button.setTitleColor(.black, for: .normal)
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 3
        return button
    }()
    
    // bottom tool bar:
    let gridButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
            button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
       return button
    }()
    
    let listButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.tintColor = UIColor(white: 0, alpha: 0.5)
            button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
            button.tintColor = UIColor(white: 0, alpha: 0.5)
            button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        return button
    }()
    
    // MARK: - Int frame:
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupProfileImage()
        self.setupBottomToolBar()
        self.setupUsernameLabel()
        self.setupStateView()
        self.setupEditProfileButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init(coder:) has not been implemented")
    }
    
    // MARK: - SetupUI funcs :
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
    
    // MARK: - Private Funcs :
    private func loadProfileImage() {
        
        guard let urlString = self.user?.profileImageStringUrl else {
            LogUtils.LogDebug(type: .error, message: "urlString is nil")
            return
        }
        guard let profileImageUrl = URL(string: urlString) else {
            LogUtils.LogDebug(type: .error, message: "url is not valid")
            return
        }

        URLSession.shared.dataTask(with: profileImageUrl ) { (data, response, error) in
            
            guard error == nil else {
                LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
                return
            }
            // check response value == 200 HTTP
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    LogUtils.LogDebug(type: .error, message: "Status code: \(httpResponse.statusCode)")
                }
            } else {
                LogUtils.LogDebug(type: .error, message: "response is nil")
            }
            
            if profileImageUrl.absoluteString != self.user?.profileImageStringUrl {
                return
            }
            
            // check data:
            guard let data = data else {
                LogUtils.LogDebug(type: .error, message: "data is nil")
                return
            }
            
            DispatchQueue.main.async {
                let profileImage = UIImage(data: data)
                self.profileImageView.image = profileImage
            }
            
        }.resume()
 
    }
    
    
    
    
}
