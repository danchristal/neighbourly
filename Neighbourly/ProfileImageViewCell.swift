//
//  ProfileImageViewCell.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-24.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit

class ProfileImageViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    let sharedUser = User.shared
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel.text = sharedUser.getName()
        
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.clipsToBounds = true
        
        
        if let url = sharedUser.getImageUrl() {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: url)
        }
        
        // Initialization code
    }

}
