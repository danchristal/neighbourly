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

    override func viewDidLoad() {
        super.viewDidLoad()

              //Add pop-over button for center tabbar item
        
//                DispatchQueue.main.async(execute: {
//                    let button: UIButton = UIButton(type: .custom)
//                    let win:UIWindow = UIApplication.shared.delegate!.window!!
//        
//                    button.frame = CGRect(x: 0.0, y: win.frame.size.height - 65, width: 55, height: 55)
//                    button.center = CGPoint(x:win.center.x , y: button.center.y)
//        
//                    button.setBackgroundImage(#imageLiteral(resourceName: "704-compose") , for: .normal)
//                    button.setBackgroundImage(#imageLiteral(resourceName: "704-compose"), for: .highlighted)
//                    win.addSubview(button)
//                })
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarViewController.receivedNotification(_:)), name: NSNotification.Name(rawValue: "didReceiveNotification"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func receivedNotification(_ notification: Notification) {
        let userInfo = notification.userInfo
        guard let remoteNotification = userInfo?["notification"] as? UNNotification else { return }
        let content = remoteNotification.request.content

        let tabArray = self.tabBar.items as Array!
        let tabItem = tabArray?[3] as UITabBarItem!
        tabItem?.badgeValue = content.badge?.stringValue
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
