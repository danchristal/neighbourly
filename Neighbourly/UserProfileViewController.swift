//
//  UserProfileViewController.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-24.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit
import FirebaseAuth


class UserProfileViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        tableView.separatorStyle = .none
        tableView.contentInset.top = 20
        tableView.allowsSelection = false
    }

    @IBAction func didTapSignOut(_ sender: UIButton) {

        try! FIRAuth.auth()!.signOut()
       
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginVC

    }
    
    
    @IBAction func didTapMyItems(_ sender: UIButton) {
        performSegue(withIdentifier: "showMyItems", sender: self)
    }
}
