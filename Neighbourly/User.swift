//
//  User.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-24.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit
import GoogleSignIn

class User: NSObject {
    
    static let shared = User()
    
    public static var fullName: String?
    private static var givenName: String?
    private static var familyName: String?
    internal static var email: String?
    private static var hasImage: Bool = false
    internal static var imageUrl: URL? = nil
    
    override private init() {
        super.init()
    }
    
    
    func setup(withGoogleUser user: GIDGoogleUser){
        
        User.fullName = user.profile.name
        User.givenName = user.profile.givenName
        User.familyName = user.profile.familyName
        User.email = user.profile.email
        User.hasImage = user.profile.hasImage
        
        if(User.hasImage){
            let dimension = round(120 * UIScreen.main.scale)
            User.imageUrl = user.profile.imageURL(withDimension: UInt(dimension))
        }
    }
    
    func getName() -> String? {
        return User.fullName
    }
    
    
    func getImageUrl() -> String? {
        if (User.hasImage){
            return "\(User.imageUrl!)"
        }
        return nil
    }
    
}
