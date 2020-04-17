//
//  FeedCell.swift
//  like_instagram_used_by_firebase
//
//  Created by JONGWOO JIN on 2020/04/16.
//  Copyright © 2020 JONGWOO JIN. All rights reserved.
//

import UIKit
import Firebase
import OneSignal

class FeedCell: UITableViewCell {

    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var documentIdLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func likeButtonClicked(_ sender: Any) {
        let fireStoreData = Firestore.firestore()
        
        if let likeCount = Int(likeLabel.text!) {
            let likeStore = ["likes" : likeCount + 1] as [String : Any]
            fireStoreData.collection("Posts").document(documentIdLabel.text!).setData(likeStore, merge: true)
        }
        
        let userEmail = userEmailLabel.text!
        fireStoreData.collection("PlayerId").whereField("email", isEqualTo: userEmail).getDocuments { (snapshot, error) in
            if error == nil {
                if snapshot != nil && snapshot?.isEmpty == false {
                    for document in snapshot!.documents {
                        if let playerId = document.get("player_id") as? String {
                            //Push Notification
                            OneSignal.postNotification(["contents": ["en": "\(Auth.auth().currentUser!.email!) liked your post"], "include_player_ids": ["\(playerId)"]])
                        }
                    }
                }
            }
        }
        
    }
    
}
