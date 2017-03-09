//
//  LoginViewController.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-18.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate  {
    
    var signInButton: GIDSignInButton!
    private var ref: FIRDatabaseReference!
    let sharedUser = User.shared



    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        
        GIDSignIn.sharedInstance().signInSilently() //sign in silently if already authenticated

        
        if let image = UIImage(named: "Dawn-1536x2048"){
            view.layer.backgroundColor = UIColor(patternImage: image).cgColor
        }
        
        // Configure the sign-in button look/feel
        signInButton = GIDSignInButton(frame: CGRect(x: 0, y: 0, width: 230, height: 48))
        signInButton.center = view.center
        signInButton.style = .standard
        view.addSubview(signInButton)
        
        ref = FIRDatabase.database().reference()

        
    }
    
   // func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!){
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                          accessToken: (authentication?.accessToken)!)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (FIRUser, error) in
            
            if let error = error{
                print(error.localizedDescription)
                return
            }
            
            if FIRUser != nil{
                
                let uid = FIRAuth.auth()?.currentUser?.uid
                let token = FIRInstanceID.instanceID().token()
                self.sharedUser.setup(withGoogleUser: user, firebaseUID: uid!, token: token!)
                
                
                print("uid: \(uid!)")
                //segue to post login view
                self.performSegue(withIdentifier: "login", sender: self)
                
                
                let userRef = self.ref.database.reference().child("users")
                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.hasChild(uid!) {
                        //create user with data from firebase
                        print("user exists")

                        let childUpdates = ["/users/\(uid!)/installToken": token]
                        self.ref.updateChildValues(childUpdates)
                    }
                    else{
                        //post sharedUser to Firebase
                        
                        var userPost = self.sharedUser.toJSON()
                        if let url = userPost["imageUrl"] as? URL{ //Convert URL to String for JSON
                            userPost["imageUrl"] = url.absoluteString
                        }
                        
                        userPost["token"] = token
                    
                        
                        let childUpdates = ["/users/\(uid!)/": userPost]
                        self.ref.updateChildValues(childUpdates)
                        
                    }
                })
            }
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        try! FIRAuth.auth()!.signOut()
    }


    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
