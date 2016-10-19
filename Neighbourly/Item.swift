//
//  Item.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-17.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit
import FirebaseDatabase

struct Item {

    var description: String
    var imageURL: String
    //var username: String
    //let hashtags: Set? = nil
    
    init(imageURL: String, description: String) {
        self.description = description
        self.imageURL = imageURL
    }
    
    init(snapshot: FIRDataSnapshot){
        let snapshotValue = snapshot.value as! [String:String]
        description = snapshotValue["description"]!
        imageURL = snapshotValue["imageURL"]!
        
    }
    
}
