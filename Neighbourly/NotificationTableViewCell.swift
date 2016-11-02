//
//  NotificationTableViewCell.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-27.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit


class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var currentItemLabel: UILabel!
    @IBOutlet weak var newItemLabel: UILabel!
    
    @IBOutlet weak var newItemImageView: UIImageView! {
        didSet{
            newItemImageView.layer.cornerRadius = 40
        }
    }

    @IBOutlet weak var currentItemImageView: UIImageView!{
        didSet{
            currentItemImageView.layer.cornerRadius = 40
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
