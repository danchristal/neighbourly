//
//  TabBarViewController.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-24.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit
import UserNotifications

class TabBarViewController: UITabBarController {
    
    @IBOutlet weak var myTabBar: UITabBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add pop-over button for center tabbar item
        
        let button: UIButton = UIButton(type: .custom)
        let win:UIWindow = UIApplication.shared.delegate!.window!!
        
        button.frame = CGRect(x: 0.0, y: win.frame.size.height - 35, width: 55, height: 55)
        button.center = CGPoint(x:win.center.x , y: button.center.y)
        
        win.addSubview(button)
        
        button.addTarget(self, action: #selector(TabBarViewController.showNewPostVC), for: .touchDown)
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarViewController.receivedNotification(_:)), name: NSNotification.Name(rawValue: "didReceiveNotification"), object: nil)
        
        
        configureView()
        
    }
    
    func showNewPostVC(sender: UIButton) {
        
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        guard let newPostVC = storyboard.instantiateViewController(withIdentifier: "newItemPost") as? PostItemViewController else{return}
        newPostVC.modalPresentationStyle = .overCurrentContext
        
        
        self.present(newPostVC, animated: true, completion: nil)
    }
    
    func configureView() {
        
        // Change the font and size of nav bar text
        if let navBarFont = UIFont(name: "AmaticSC-Bold", size: 40.0) {
            let navBarAttributesDictionary: [String: Any]? = [
                NSForegroundColorAttributeName: UIColor.black,
                NSFontAttributeName: navBarFont
            ]
            //navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
            UINavigationBar.appearance().titleTextAttributes = navBarAttributesDictionary
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var tabFrame = myTabBar.frame
        tabFrame.size.height = 35
        tabFrame.origin.y = view.frame.size.height - 35
        tabBar.frame = tabFrame
    }
    
    func receivedNotification(_ notification: Notification) {
        //let userInfo = notification.userInfo
        //guard let remoteNotification = userInfo?["notification"] as? UNNotification else { return }
        //let content = remoteNotification.request.content
        
        //let tabArray = self.tabBar.items as Array!
        //let tabItem = tabArray?[3] as UITabBarItem!
        
//
//        
//        if let badgeValue = tabItem?.badgeValue {
//            if var badgeValueInt = Int(badgeValue) {
//                badgeValueInt += Int(content.badge!)
//                tabItem?.badgeValue = "\(badgeValueInt)"
//            }
//        } else {
//            tabItem?.badgeValue = "1"
//        }
        
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
