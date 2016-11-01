//
//  User.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-24.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit
import GoogleSignIn

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
    
    func setup(withGoogleUser user: GIDGoogleUser, firebaseUID uid: String, token: String){
        
        fullName = user.profile.name
        givenName = user.profile.givenName
        familyName = user.profile.familyName
        email = user.profile.email
        hasImage = user.profile.hasImage
        firebaseUID = uid
        installToken = token
        
        if(hasImage){
            let dimension = round(120 * UIScreen.main.scale)
            imageUrl = user.profile.imageURL(withDimension: UInt(dimension))
        }
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
