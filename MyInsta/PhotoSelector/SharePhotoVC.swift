//
//  SharePhotoVC.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/7/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoVC: UIViewController {
    
    // MARK: - Properties:
    var selectedImage: UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }
    
    // MARK: - Create UI :
    let imageView: UIImageView = {
       
        let iv = UIImageView()
            iv.backgroundColor = UIColor.lightGray
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
        
        return iv
    }()
    
    let textView: UITextView = {
       
        let tv = UITextView()
            tv.font = UIFont.systemFont(ofSize: 14)
        
        return tv
    }()
    
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.rgb(r: 240, g: 240, b: 240)
        self.setupShareButton()
        self.setupImageAndTextView()
    }
    
    // MARK: - Setup When ViewDidLoad:
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    private func setupShareButton() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleShareButtonPressed))
    }
    
    private func setupImageAndTextView() {
        
        let containerView = UIView()
            containerView.backgroundColor = .white
        
        // add container:
        self.view.addSubview(containerView)
        containerView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
        containerView.addSubview(imageView)
        self.imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)
        
        containerView.addSubview(textView)
        self.textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    // MARK: - Handle Button Pressed :
    @objc func handleShareButtonPressed() {
        
        // get the text
        guard let caption = self.textView.text else {
            Logger.LogDebug(type: .warning, message: "Caption is nil")
            return
        }
        guard caption.count > 0 else {
            Logger.LogDebug(type: .error, message: "Caption is empty")
            return
        }
        // get the image:
        guard let image = selectedImage else {
            Logger.LogDebug(type: .error, message: "selectedImage is nil")
            return
        }
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            Logger.LogDebug(type: .error, message: "imageData is nil")
            return
        }
        
        // disable shareButton:
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        let uuid = UUID().uuidString
        storageRef.child("posts").child(uuid).putData(imageData, metadata: nil) { [unowned self](metadata, error) in
            
            guard error == nil else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                Logger.LogDebug(type: .error, message: error!.localizedDescription)
                return
            }
            Logger.LogDebug(type: .info, message: "Upload image successfully")
            
            // get postImageUrl:
            var postImageUrl = ""
            storageRef.child("posts").child(uuid).downloadURL(completion: { [unowned self](url, error) in
                
                guard error == nil else {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    Logger.LogDebug(type: .error, message: error!.localizedDescription)
                    return
                }
                guard let url = url else {
                    Logger.LogDebug(type: .error, message: "postImageUrl is nil")
                    return
                }
                
                postImageUrl = url.absoluteString
                
                // save to db:
                guard let uid = Auth.auth().currentUser?.uid else {
                    Logger.LogDebug(type: .error, message: "uid is nil")
                    return
                }
                let userPostRef = databaseRef.child("posts").child(uid)
                let ref = userPostRef.childByAutoId()
                
                let width = self.selectedImage!.size.width
                let height = self.selectedImage!.size.height
                let imageSize = ["width": width, "height": height]
                let info = ["caption": caption,
                            "imageUrl": postImageUrl,
                            "imageSize": imageSize,
                            "createdTime": Date().timeIntervalSince1970]  as [String : Any]
                
                ref.updateChildValues(info, withCompletionBlock: { [unowned self](error, ref) in
                    
                    guard error == nil else {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        Logger.LogDebug(type: .error, message: error!.localizedDescription)
                        return
                    }
                    Logger.LogDebug(type: .info, message: "Save to DB successfully")
                    self.dismiss(animated: true, completion: nil)
                    // post to homeVC know that new post were posted
                    NotificationCenter.default.post(name: CustomNotification.UpdateNewPost, object: nil)
                })
                
            }) // end downloadURL{}
        } // end putData{}
        
    } // end handleShareButton()
    
}
