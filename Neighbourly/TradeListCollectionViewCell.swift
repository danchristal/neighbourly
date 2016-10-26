//
//  TradeListCollectionViewCell.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-25.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit

class TradeListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var downloadTask : URLSessionDownloadTask? = nil
    
    override func prepareForReuse(){
        super.prepareForReuse()
        downloadTask?.suspend()
        imageView.image = nil
    }
}
