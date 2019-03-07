//
//  LoginVC.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/5/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    // MARK: - Create UI :
    
    // top view:
    let logoContainerView: UIView = {
        
        let view = UIView()
            view.backgroundColor = UIColor.rgb(r: 0, g: 120, b: 175)
        
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFill
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }()
    
    // fields:
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
    
    let loginButton: UIButton = {
        
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setTitle("Login", for: UIControl.State.normal)
        button.backgroundColor = UIColor.rgb(r: 149, g: 204, b: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(UIColor.white, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        return button
    }()
    
    
    let dontHaveAccountButton: UIButton = {
       let attributedText = NSMutableAttributedString(string: "Don't have an account?",
                                                        attributes: [.foregroundColor : UIColor.gray,
                                                                     .font : UIFont.systemFont(ofSize: 13)])
        attributedText.append(NSAttributedString(string: " Sign Up", attributes: [NSAttributedString.Key.foregroundColor : UIColor.rgb(r: 17, g: 154, b: 237),
                                                                                 .font : UIFont.systemFont(ofSize: 14, weight: .bold)]))
        
       let button = UIButton(type: .system)
           button.setAttributedTitle(attributedText, for: .normal)
           button.addTarget(self, action: #selector(handleDontHaveAccountButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = .white
        setupSignUpButton()
        setupLogoContainerView()
        setupInputFields()
        self.dismissKeyboardWhenTappingArround()
    }
    
    // MARK: - Setup UI :
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupSignUpButton() {
        self.view.addSubview(dontHaveAccountButton)
        self.dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    private func setupLogoContainerView() {
        self.view.addSubview(logoContainerView)
        self.logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
    }

    private func setupInputFields() {
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
            stackView.spacing = 10
            stackView.distribution = .fillEqually
            stackView.axis = .vertical
        
        self.view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 140)
    }

    // MARK: - Handle Button Tap :
    
    @objc func handleLogin() {
        let email = self.emailTextField.text!
        let password = self.passwordTextField.text!
        
        Auth.auth().signIn(withEmail: email, password: password) { [unowned self](result, error) in
            guard error == nil else {
                Logger.LogDebug(type: .error, message: error!.localizedDescription)
                return
            }
            
            guard let mainTabBarVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {
                Logger.LogDebug(type: .error, message: "Fail to get mainTabBarVC")
                return
            }
            mainTabBarVC.setupVC()
            Logger.LogDebug(type: .info, message: "Login success")
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc func handleTextInputField() {
        let isFormValid = (emailTextField.text?.count ?? 0 > 0) &&  (passwordTextField.text?.count ?? 0 > 0 )
        self.loginButton.backgroundColor = isFormValid ? UIColor.rgb(r: 17, g: 154, b: 237) : UIColor.rgb(r: 149, g: 204, b: 244)
        self.loginButton.isEnabled = isFormValid
    }
    
    @objc func handleDontHaveAccountButtonPressed() {
        let registerVC = RegisterVC()
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    // MARK: -
    func dismissKeyboardWhenTappingArround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }

    
    
}
