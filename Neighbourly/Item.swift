//
//  Item.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-17.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import CoreLocation

let imageCache = NSCache<NSString, UIImage>()

struct Item : Equatable {

    var description: String
    var imageURL: String
    var locationString: String?
    var location: CLLocationCoordinate2D?
    var postID: String
    var userID: String
    var username: String
    var userImageUrl: String?
    var tradeScore: String
    var title: String
    
    init(snapshot: FIRDataSnapshot){
        let snapshotValue = snapshot.value as! [String:Any]
        userID = snapshotValue["author"] as! String
        postID = snapshot.key
        username = snapshotValue["authorName"] as! String
        userImageUrl = snapshotValue["authorImageUrl"] as? String
        description = snapshotValue["description"] as! String
        imageURL = snapshotValue["imageURL"] as! String
        locationString = snapshotValue["location"] as? String
        tradeScore = snapshotValue["tradeScore"] as! String
        title = snapshotValue["title"] as! String
        
        if let latitude = snapshotValue["latitude"] as? Double, let longitude = snapshotValue["longitude"] as? Double {
            location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
    }
    
    static func ==(lhs: Item, rhs: Item) -> Bool {
        return lhs.postID == rhs.postID 
    }
    
    func downloadImage(){
        
    }
    
}
