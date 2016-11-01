//
//  Protocol+CellHasDownloadTask.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-26.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit

protocol CellHasDownloadTask {
    var downloadTask : URLSessionDownloadTask? {get set}
    var cellImageView: UIImageView! {get set}
    
    mutating func loadsImage(urlString: String, completion:@escaping (UIImage) -> Void )
}

extension CellHasDownloadTask {
    
    mutating func loadsImage(urlString: String, completion:@escaping (UIImage) -> Void ){
        self.cellImageView.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as UIImage! {
            completion(cachedImage)
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        downloadTask = URLSession.shared.downloadTask(with: url!, completionHandler: { (url, response, error) in
            //download hit an error so lets return out
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = try? Data(contentsOf: url!) else { return }
            DispatchQueue.main.async { //return image on main queue
                if let downloadedImage = UIImage(data: data) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    completion(downloadedImage)
                }
            }
        })
        downloadTask?.resume()
    }
}
