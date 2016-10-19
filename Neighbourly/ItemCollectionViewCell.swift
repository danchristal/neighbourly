//
//  ItemCollectionViewCell.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-17.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import Foundation
import UIKit

class ItemCollectionViewCell : UICollectionViewCell{
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    var downloadTask : URLSessionDownloadTask? = nil
    
    override func prepareForReuse(){
        super.prepareForReuse()
        downloadTask?.suspend()
        imageView.image = nil
    }

    
}
