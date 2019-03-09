//
//  CommentInputAccessoryView.swift
//  MyInsta
//
//  Created by Nguyen Lam on 3/9/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import Firebase

protocol CommentInputAccessoryViewDelegate: class {
    
    func didSendComment(with content: String)
    
}

class CommentInputAccessoryView: UIView, UITextViewDelegate {
    
    // MARK: -
    weak var delegate: CommentInputAccessoryViewDelegate?

    private var lineSeperator: UIView = {
        let lineSeperator = UIView()
            lineSeperator.backgroundColor = UIColor.rgb(r: 230, g: 230, b: 230)
        
        return lineSeperator
    }()
    
    private lazy var sendButton: UIButton = {
        
        let sendButton = UIButton(type: UIButton.ButtonType.system)
            sendButton.setTitle("Send", for: .normal)
            sendButton.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: UIControl.State.normal)
            sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            sendButton.addTarget(self, action: #selector(handleSendButton), for: UIControl.Event.touchUpInside)
        
        return sendButton
    }()
    
    private var inputTextView: UITextView = {
        let inputTextView = UITextView()
            inputTextView.isScrollEnabled = false
            inputTextView.font = UIFont.systemFont(ofSize: 16)
        
        return inputTextView
    }()
    
    // MARK: -
    
    private func setTextViewPlaceholder() {
        self.inputTextView.text = "Enter comment"
        self.inputTextView.textColor = UIColor.lightGray
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            self.setTextViewPlaceholder()
        }
        
    }
    
    @objc func handleSendButton() {
        guard let text = self.inputTextView.text, text.count > 0 else {
            return
        }
        delegate?.didSendComment(with: text)
    }
    
    func handleInputTextViewAfterSent() {
        self.inputTextView.text = nil
        self.hideInputTextView()
    }
    
    func showInputTextView() {
        self.inputTextView.becomeFirstResponder()
    }
    
    func hideInputTextView() {
        self.inputTextView.resignFirstResponder()
    }
    
    func didBeginningEditTextView() {
        
    }
    
    // MARK: -
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.autoresizingMask = .flexibleHeight
        
        self.backgroundColor = .white
        self.setupViews()
        self.inputTextView.delegate = self
        self.setTextViewPlaceholder()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        
        return CGSize.zero
        
    }
    
    
    // MARK: -
    private func setupViews() {
        
        self.backgroundColor = .white
        
        self.addSubview(lineSeperator)
        self.addSubview(sendButton)
        self.addSubview(inputTextView)
        
        self.lineSeperator.anchor(top: nil, left: self.leftAnchor, bottom: self.topAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        
        self.sendButton.anchor(top: nil, left: nil, bottom: self.safeAreaLayoutGuide.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 0)
        
        self.inputTextView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.safeAreaLayoutGuide.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)

    }
    
    
}

