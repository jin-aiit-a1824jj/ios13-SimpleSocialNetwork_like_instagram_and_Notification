//
//  FeedViewController.swift
//  like_instagram_used_by_firebase
//
//  Created by JONGWOO JIN on 2020/04/16.
//  Copyright © 2020 JONGWOO JIN. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import OneSignal

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var userEmailArray = [String]()
    var userCommentArray = [String]()
    var likeArray = [String]()
    var userImageArray = [String]()
    var documentIdArray = [String]()
    
    let fireStoreDatabase = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        getDataFromFirestore()
        
        //Push Notification
        //OneSignal.postNotification(["contents": ["en": "Test Message"], "include_player_ids": ["3009e210-3166-11e5-bc1b-db44eb02b120"]])
        
        let status:OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let playerId = status.subscriptionStatus.userId
        if let playerNewId = playerId {
            print("player ID : " + playerNewId)
            
            fireStoreDatabase.collection("PlayerId").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { (snapshot, error) in
                if error == nil{
                    if snapshot != nil && snapshot?.isEmpty == false {
                        for document in snapshot!.documents {
                            if let playerIDFromFirebase = document.get("player_id") as? String {
                                print("playerIDFromFirebase: " + playerIDFromFirebase)
                                
                                if playerNewId != playerIDFromFirebase {
                                    let playerIdDictionary = ["email" : Auth.auth().currentUser!.email!, "player_id" : playerNewId] as [String : Any]
                                    self.fireStoreDatabase.collection("PlayerId").addDocument(data: playerIdDictionary) { error in
                                        if error != nil {
                                            print(error?.localizedDescription as Any)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        let playerIdDictionary = ["email" : Auth.auth().currentUser!.email!, "player_id" : playerNewId] as [String : Any]
                        self.fireStoreDatabase.collection("PlayerId").addDocument(data: playerIdDictionary) { error in
                            if error != nil {
                                print(error?.localizedDescription as Any)
                            }
                        }
                    }
                }
            }
            
            
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userEmailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        cell.selectionStyle = .none
        cell.userEmailLabel.text = userEmailArray[indexPath.row]
        cell.likeLabel.text = likeArray[indexPath.row]
        cell.commentLabel.text = userCommentArray[indexPath.row]
        cell.documentIdLabel.text = documentIdArray[indexPath.row]
        
        
        cell.imageView?.sd_setImage(with: URL(string: userImageArray[indexPath.row]), placeholderImage: UIImage(named: "select.png")){ ( image, _, _, _) in
            cell.imageView?.image = image?.resize(size: CGSize(width: 374.0, height: 229.0))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400.0
    }
    
    func getDataFromFirestore() {
        
        fireStoreDatabase.collection("Posts").order(by: "date", descending: true) .addSnapshotListener{ (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                if  snapshot != nil && snapshot?.isEmpty != true {
                    
                    self.userEmailArray.removeAll(keepingCapacity: true)
                    self.userCommentArray.removeAll(keepingCapacity: true)
                    self.likeArray.removeAll(keepingCapacity: true)
                    self.userImageArray.removeAll(keepingCapacity: true)
                    self.documentIdArray.removeAll(keepingCapacity: true)
                    
                    for document in snapshot!.documents {
                        let documentID = document.documentID
                        print(documentID)
                        self.documentIdArray.append(documentID)
                        if let postedBy = document.get("postedBy") as? String {
                            self.userEmailArray.append(postedBy)
                        }
                        
                        if let postComment = document.get("postComment") as? String {
                            self.userCommentArray.append(postComment)
                        }
                        
                        if let postedlikes = document.get("likes") as? Int {
                            self.likeArray.append("\(postedlikes)")
                        }
                        
                        if let imageUrl = document.get("imageUrl") as? String {
                            self.userImageArray.append(imageUrl)
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
}

extension UIImage {
    func resize(size _size: CGSize) -> UIImage? {
        let widthRatio = _size.width / size.width
        let heightRatio = _size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
        
        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0) // 変更
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
