//
//  CommentCell.swift
//  MyInsta
//
//  Created by Nguyen Lam on 3/6/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
            self.configCell(with: comment)
        }
    }
    
    private func configCell(with comment: Comment?) {
        // set text:
        guard let username = comment?.user.username else { return }
        guard let textcomment = comment?.text else { return }
        let attributedText = NSMutableAttributedString(string: username + " ", attributes: [.font : UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: textcomment, attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        self.textView.attributedText = attributedText
        // set user profike image:
        guard let imageURL = comment?.user.profileImageStringUrl else {
            Logger.LogDebug(type: .info, message: "something nil")
            return
        }
        self.profileImageView.fetchPostImage(with: imageURL)

    }
    
    let textView: UITextView = {
       let textView = UITextView()
           textView.font = UIFont.systemFont(ofSize: 14)
           textView.isScrollEnabled = false
           textView.isEditable = false
        
        return textView
    }()
    
    let profileImageView: CustomImageView = {
       let iv = CustomImageView()
            iv.contentMode = .scaleAspectFill
            iv.backgroundColor = .red
            iv.clipsToBounds = true
        return iv
        
    }()
    
    let lineSeperator: UIView = {
       
        let line = UIView()
            line.backgroundColor = UIColor.rgb(r: 230, g: 230, b: 230)
        
        return line
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        self.addSubview(textView)
        self.addSubview(profileImageView)
        self.addSubview(lineSeperator)
        
        self.profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
            profileImageView.layer.cornerRadius = 40/2
        
        self.textView.anchor(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        self.lineSeperator.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
    }
}
