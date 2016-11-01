//
//  TradeListCollectionViewCell.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-25.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit


class TradeListCollectionViewCell: UICollectionViewCell, CellHasDownloadTask {
    
    @IBOutlet weak var cellImageView: UIImageView!
    var downloadTask : URLSessionDownloadTask? = nil
    
    override func prepareForReuse(){
        super.prepareForReuse()
        downloadTask?.suspend()
        cellImageView.image = nil
    }
    
}
