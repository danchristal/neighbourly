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

struct Item {

    var description: String
    var imageURL: String
    var locationString: String?
    var location: CLLocationCoordinate2D!
    var postID: String!
    var userID: String!
    //var username: String
    //let hashtags: Set? = nil
    
    init(imageURL: String, description: String) {
        self.description = description
        self.imageURL = imageURL
    }
    
    init(snapshot: FIRDataSnapshot){
        let snapshotValue = snapshot.value as! [String:Any]
        userID = snapshotValue["author"] as! String
        postID = snapshot.key
        print("Item postID: \(postID!)")
        description = snapshotValue["description"] as! String
        imageURL = snapshotValue["imageURL"] as! String
        locationString = snapshotValue["location"] as? String
        location = CLLocationCoordinate2D(latitude: snapshotValue["latitude"] as! Double, longitude: snapshotValue["longitude"] as! Double)
    }
    
    func downloadImage(){
        
    }
    
}
