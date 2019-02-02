//
//  ViewController.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/2/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import Firebase


class RegisterVC: UIViewController {
    
    
    // MARK: - View Create :
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setImage(UIImage(named: "plus_photo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.keyboardType = UIKeyboardType.emailAddress
        textField.addTarget(self, action: #selector(handleTextInputField), for: .editingChanged)
        
        return textField
    }()
    
    
    let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.keyboardType = UIKeyboardType.alphabet
        textField.addTarget(self, action: #selector(handleTextInputField), for: .editingChanged)
        
        return textField
    }()
    
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.isSecureTextEntry = true
        textField.keyboardType = UIKeyboardType.alphabet
        textField.addTarget(self, action: #selector(handleTextInputField), for: .editingChanged)
        
        return textField
    }()
    
    @objc func handleTextInputField() {
        let isFormValid = (emailTextField.text?.count ?? 0 > 0) && (usernameTextField.text?.count ?? 0 > 0) && (passwordTextField.text?.count ?? 0 > 0 )
        self.signUpButton.backgroundColor = isFormValid ? UIColor.rgb(r: 17, g: 154, b: 237) : UIColor.rgb(r: 149, g: 204, b: 244)
        self.signUpButton.isEnabled = isFormValid
    }
    
    let signUpButton: UIButton = {
        
        let button = UIButton(type: UIButton.ButtonType.system)
            button.setTitle("Sign Up", for: UIControl.State.normal)
            button.backgroundColor = UIColor.rgb(r: 149, g: 204, b: 244)
            button.layer.cornerRadius = 5
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            button.setTitleColor(UIColor.white, for: .normal)
            button.isEnabled = false
            button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleSignUp() {

         let email = emailTextField.text!
         let username = usernameTextField.text!
         let password = passwordTextField.text!
        // create user:
        Auth.auth().createUser(withEmail: email, password: password) { [unowned self](result, error) in
            guard error == nil else {
                LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
                return
            }
            LogUtils.LogDebug(type: .info, message: "Create user success with uid: \(result!.user.uid)")

            // get profileImage data:
            guard let profileImage = self.plusPhotoButton.imageView?.image else {
                LogUtils.LogDebug(type: .warning, message: "profileImage is nil")
                return
            }
            guard let profileImageData = profileImage.jpegData(compressionQuality: 0.5) else {
                LogUtils.LogDebug(type: .warning, message: "profileImageData is nil")
                return
            }
            // upload profileImageData:
            let uuidString = UUID().uuidString
            storageRef.child("profile_images").child(uuidString).putData(profileImageData, metadata: nil, completion: { (metadata, error) in
                
                guard error == nil else {
                    LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
                    return
                }
                LogUtils.LogDebug(type: .info, message: "upload profileImage success")
                
                // upload user's info data:
                var profileImageUrl = ""
                storageRef.child("profile_images").child(uuidString).downloadURL(completion: { (url, error) in
                    guard error == nil else {
                        LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
                        return
                    }
                    guard let url = url else {
                        LogUtils.LogDebug(type: .error, message: "Url is nil")
                        return
                    }
                    profileImageUrl = url.absoluteString
                    
                    let userInfoDict = ["username" : username,
                                        "profileImageUrl" : profileImageUrl]
                    
                    let uid = result?.user.uid
                    databaseRef.child("users").child(uid!).updateChildValues(userInfoDict, withCompletionBlock: { (error, ref) in
                        guard error == nil else {
                            LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
                            return
                        }
                        LogUtils.LogDebug(type: .info, message: "Upload user's info success")
                    })
                    
                    
                })
                
            })
            

        } // end Auth.auth().createUser closure


    } // end handleFunc here
    
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(plusPhotoButton)
        
        plusPhotoButton.anchor(top: view.topAnchor, paddingTop: 40, left: nil, paddingLeft: nil, right: nil, paddingRight: nil, bottom: nil, paddingBottom: nil, width: 140, height: 140)
        
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        self.setupInputFields()
    }
    
    fileprivate func setupInputFields() {
        
        
        let stackView = UIStackView(arrangedSubviews: [ self.emailTextField,
                                                       self.usernameTextField,
                                                       self.passwordTextField,
                                                       self.signUpButton ])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.anchor(top: plusPhotoButton.bottomAnchor, paddingTop: 20, left: view.leftAnchor, paddingLeft: 40, right: view.rightAnchor, paddingRight: -40, bottom: nil, paddingBottom: nil, width: nil, height: 200)
        
    }
    
}
// MARK: - ImagePickerCOntrollerDelegate :
extension RegisterVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage {
            self.plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            self.plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        self.plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        self.plusPhotoButton.layer.masksToBounds = true
        self.plusPhotoButton.layer.borderColor = UIColor(white: 0, alpha: 0.5).cgColor
        self.plusPhotoButton.layer.borderWidth = 3
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
