//
//  ProfileImageViewCell.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-24.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileImageViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    private var ref: FIRDatabaseReference!
    private var myScore: Int = 0
    
    
    let sharedUser = User.shared
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel.text = sharedUser.getName()
        
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.clipsToBounds = true
        
        
        if let url = sharedUser.getImageUrl() {
            profileImageView.loadImage(urlString: url)
        }
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        ref = FIRDatabase.database().reference()
        let postRef = ref.database.reference().child("posts")
        
        postRef.queryOrdered(byChild: "author").queryEqual(toValue: uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children{
                let item = Item(snapshot: child as! FIRDataSnapshot)
                
                let itemScore = Int(item.tradeScore)!
                
                self.myScore += itemScore
                
            }
            DispatchQueue.main.async(execute: {
                self.scoreLabel.text = "Score: \(self.myScore)"
            })
            
        })
        
        
        
        
    }

    
    
    
}
