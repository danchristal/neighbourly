//
//  ItemCollectionViewCell.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-17.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import Foundation
import UIKit





class ItemCollectionViewCell : UICollectionViewCell, CellHasDownloadTask {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    var downloadTask : URLSessionDownloadTask? = nil
    var delegate: ItemCollectionViewController?
    
    
    @IBAction func tradePressed(_ sender: UIButton){
        delegate?.tradeButtonPressed(cell: self, sender: sender)
        
    }
    
    override func prepareForReuse(){
        super.prepareForReuse()
        downloadTask?.suspend()
        imageView.image = nil
    }
    
}


