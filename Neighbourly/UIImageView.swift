//
//  Extension+UIImageView.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-17.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit



extension UIImageView {
    func loadImage(urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as UIImage! {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        //URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
        URLSession.shared.downloadTask(with: url!, completionHandler: { (url, response, error) in
            //download hit an error so lets return out
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            
            guard let data = try? Data(contentsOf: url!) else { return }
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                }
                
            }
            
        }).resume()
        
    }
}


