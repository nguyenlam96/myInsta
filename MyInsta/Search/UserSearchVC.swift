//
//  UserSearchVC.swift
//  MyInsta
//
//  Created by Nguyen Lam on 2/26/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import Firebase

class UserSearchVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // MARK: -
    let cellId = "cellId"
    var fetchedUsers = [User]()
    var isFiltering = false
    var filteredFetchedUsers = [User]()
    lazy var searchBar: UISearchBar = {
       let sb = UISearchBar()
            sb.placeholder = "Enter username"
            sb.barTintColor = UIColor.lightGray
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(r: 230, g: 230, b: 230)
            sb.delegate = self
        
        return sb
    }()
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = .white // defaul CollectionView's backgroundColor is black
        self.setupSearchBar()
        self.collectionView.register(UserSearchCell.self, forCellWithReuseIdentifier: self.cellId)
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.keyboardDismissMode = .onDrag
        self.fetchUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.searchBar.isHidden = false
    }
    
    // MARK: -
    private func setupSearchBar() {
        
        self.navigationController?.navigationBar.addSubview(self.searchBar)
        let navBar = self.navigationController?.navigationBar
        self.searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
    }
    
    // MARK: -
    
    fileprivate func fetchUser() {

        databaseRef.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            guard let dictionaries = snapshot.value as? [String:Any] else {
                Logger.LogDebug(type: .warning, message: "Can't cast snapshot value to dictionaries")
                return
            }
            let currentUid = Auth.auth().currentUser?.uid
            for (key,value) in dictionaries { /// key = uid, value = userInfoDict
                if key == currentUid {
                    continue
                }
                if let userDict = value as? [String:Any]  {
                    let user = User(uid: key, dictionary: userDict)
                    self.fetchedUsers.append(user)
                } else {
                    Logger.LogDebug(type: .warning, message: "this value can't cast to userDict")
                }
            }
            // ordered the result:
            self.fetchedUsers.sort(by: { (user1, user2) -> Bool in
                user1.username.compare(user2.username) == .orderedAscending
            })
            
            // reload data:
            self.collectionView.reloadData()
            
            
        }) { (error) in
            Logger.LogDebug(type: .error, message: error.localizedDescription)
            return
        }
    }
    
    // MARK: -
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isFiltering ? self.filteredFetchedUsers.count : self.fetchedUsers.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! UserSearchCell
        let user = isFiltering ? self.filteredFetchedUsers[indexPath.item] : self.fetchedUsers[indexPath.item]
        cell.user = user

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 66)
    }
    // MARK: -
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.searchBar.isHidden = true
        self.searchBar.resignFirstResponder()
        
        let user = isFiltering ? self.filteredFetchedUsers[indexPath.row] : self.fetchedUsers[indexPath.row]
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout() )
            userProfileVC.user = user
        self.navigationController?.pushViewController(userProfileVC, animated: true)
        
    }
    
}
extension UserSearchVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchText.isEmpty {
            self.isFiltering = true
            self.filteredFetchedUsers = self.fetchedUsers.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
            self.collectionView.reloadData()
        } else {
            self.isFiltering = false
            self.collectionView.reloadData()
        }

    }
    
}
