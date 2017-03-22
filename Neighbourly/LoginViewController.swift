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

class LoginViewController: UIViewController  {
    
    private var ref: FIRDatabaseReference!
    let sharedUser = User.shared
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        FIRAuth.auth()?.signIn(withEmail: email.text!, password: password.text!, completion: { (user, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let user = user {
                
                let uid = user.uid
                print("uid: \(uid)")
                
                let token = FIRInstanceID.instanceID().token()
                
                //create user object from database
                self.sharedUser.setup(firebaseUID: uid, installToken: token)
                
                
                let userRef = self.ref.database.reference().child("users")
                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    //if user already exists, update install token
                    if snapshot.hasChild(uid) {
                        
                        
                        let childUpdates = ["/users/\(uid)/installToken": token]
                        self.ref.updateChildValues(childUpdates)
                    }
                    else{
                        //else create new user entry in database
                        var userJson = self.sharedUser.toJSON()
                        if let url = userJson["imageUrl"] as? URL{ //Convert URL to String for JSON
                            userJson["imageUrl"] = url.absoluteString
                        }
                        
                        
                        let childUpdates = ["/users/\(uid)/": userJson]
                        self.ref.updateChildValues(childUpdates)
                        
                    }
                })
                
                
                
                
                
                //segue to post login view
                self.performSegue(withIdentifier: "login", sender: self)
                
            }
            
            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let image = UIImage(named: "Dawn-1536x2048"){
            view.layer.backgroundColor = UIColor(patternImage: image).cgColor
        }
        
        
        ref = FIRDatabase.database().reference()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if let user = user {
                let token = FIRInstanceID.instanceID().token()
                
                self.sharedUser.setup(firebaseUID: user.uid, installToken: token)
                
                let userRef = self.ref.database.reference().child("users")
                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    
                    if snapshot.hasChild(user.uid) { //update push token
                        let childUpdates = ["/users/\(user.uid)/installToken": token]
                        self.ref.updateChildValues(childUpdates)
                    }
                    self.performSegue(withIdentifier: "login", sender: self)
                })
                

            }
        })
        
    }
    
    // func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    /*
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
     
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
