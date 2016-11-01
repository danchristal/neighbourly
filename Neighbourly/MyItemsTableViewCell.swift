//
//  MyItemsTableViewCell.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-31.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit

class MyItemsTableViewCell: UITableViewCell, CellHasDownloadTask {

    @IBOutlet weak var cellImageView: UIImageView!
   
    
    var downloadTask : URLSessionDownloadTask? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func prepareForReuse(){
        super.prepareForReuse()
        downloadTask?.suspend()
        cellImageView.image = nil
    }

}
