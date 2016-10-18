//
//  Item.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-17.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit

class Item {

    var description: String
    var imageURL: String
    var username: String
    //let hashtags: Set? = nil
    
    init(imageURL: String, description: String, username: String) {
        self.description = description
        self.imageURL = imageURL
        self.username = username
    }
    
}
