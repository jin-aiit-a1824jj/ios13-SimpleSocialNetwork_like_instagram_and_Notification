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

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var userEmailArray = [String]()
    var userCommentArray = [String]()
    var likeArray = [String]()
    var userImageArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        getDataFromFirestore()
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
        //cell.imageView?.image = UIImage(named: "select.png")
        cell.imageView?.sd_setImage(with: URL(string: userImageArray[indexPath.row]), placeholderImage: UIImage(named: "select.png"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500.0
    }
    
    func getDataFromFirestore() {
        
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("Posts").addSnapshotListener{ (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                if  snapshot != nil && snapshot?.isEmpty != true {
                    
                    self.userEmailArray.removeAll(keepingCapacity: true)
                    self.userCommentArray.removeAll(keepingCapacity: true)
                    self.likeArray.removeAll(keepingCapacity: true)
                    self.userImageArray.removeAll(keepingCapacity: true)
                    
                    for document in snapshot!.documents {
                        let documentID = document.documentID
                        print(documentID)
                        
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
