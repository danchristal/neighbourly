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

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var posterName: UILabel!
    @IBOutlet weak var posterImage: UIImageView! {
        didSet{
            posterImage.layer.cornerRadius = 15
        }
    }
    
    @IBOutlet weak var descriptionLabel: UILabel!
    var downloadTask : URLSessionDownloadTask? = nil
    weak var delegate: ItemCollectionViewController?
    
    
    @IBAction func tradePressed(_ sender: UIButton){
        delegate?.tradeButtonPressed(cell: self, sender: sender)
        
    }
    
    override func prepareForReuse(){
        super.prepareForReuse()
        downloadTask?.suspend()
        cellImageView.image = nil
        posterImage.image = nil
    }
    
}


