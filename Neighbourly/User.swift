//
//  User.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-24.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit

class User: NSObject, JSONAble {
    
    static let shared = User()
    
    internal var fullName: String?
    internal var givenName: String?
    internal var familyName: String?
    internal var email: String?
    internal var hasImage: Bool = false
    internal var imageUrl: URL? = nil
    internal var firebaseUID: String?
    internal var installToken: String?
    
    override private init() {
        super.init()
    }
    
    func setup(firebaseUID uid: String, installToken token: String?) {
        fullName = "test"
        givenName = "testy"
        familyName = "Test"
        email = "test@me.com"
        hasImage = false
        firebaseUID = uid
        installToken = token
        
    }
    
    func getName() -> String? {
        return fullName
    }

    
    func getImageUrl() -> String? {
        if (hasImage){
            return "\(imageUrl!)"
        }
        return nil
    }
    
}
