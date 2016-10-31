//
//  NotificationTableViewCell.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-27.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit


protocol TradeNotificationDelegate {
    func acceptTrade(cell: NotificationTableViewCell)
    func declineTrade(cell: NotificationTableViewCell)
}

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var currentItemLabel: UILabel!
    @IBOutlet weak var newItemLabel: UILabel!
    
    var delegate: TradeNotificationDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didPressAcceptTrade(sender: UIButton) {
        
        //swap items & remove all related trades
        delegate?.acceptTrade(cell: self)
        
    }
    
    @IBAction func didPressDeclineTrade(sender: UIButton) {
        
        //remove notification from user list
        
        delegate?.declineTrade(cell: self)
        
    }

}
