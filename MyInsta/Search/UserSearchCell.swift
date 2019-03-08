//
//  SearchCell.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/26/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit

class UserSearchCell: UICollectionViewCell {
    // MARK: -
    var user: User? {
        didSet {
            guard let user = self.user else {
                Logger.LogDebug(type: .error, message: "This User is nil")
                return
            }
            self.bindData(with: user)
            self.profileImageView.fetchPostImage(with: user.profileImageStringUrl)
            
        }
    }
    let profileImageView: CustomImageView = {
       let iv = CustomImageView()
            iv.backgroundColor = UIColor.lightGray
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

    // MARK: -
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupProfileImageView()
        self.setupUsernameLabel()
        self.setupSeperatorLine()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    func bindData(with user: User) {
        self.usernameLabel.text = user.username
    }
    
    // MARK: -
    private func setupProfileImageView() {
        self.addSubview(profileImageView)
        self.profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        self.profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        self.profileImageView.layer.cornerRadius = 50/2
    }
    private func setupUsernameLabel() {
        self.addSubview(usernameLabel)
        self.usernameLabel.anchor(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    private func setupSeperatorLine() {
        let seperatorView = UIView()
        seperatorView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.addSubview(seperatorView)
        seperatorView.anchor(top: nil, left: usernameLabel.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    
}
