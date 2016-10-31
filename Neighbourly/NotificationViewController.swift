//
//  NotificationViewController.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-27.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit
import FirebaseDatabase


class NotificationViewController: UITableViewController, TradeNotificationDelegate {
    
    var userNotifications = [[String:Any]]() {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private var ref: FIRDatabaseReference!
    private var initialDataLoaded = false
    private let sharedUser = User.shared
    private var newNotification: [String:Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset.top = 20
        
        //get reference to database
        ref = FIRDatabase.database().reference()
        
        getNotifications { (notifications) in
            
            var notificationArray = notifications.flatMap { $0.1 as? [String:Any] }
            
            while(!notificationArray.isEmpty){
                
                let notification = notificationArray.removeFirst() as! [String:String]
                let currentItemId = notification["currentItem"]
                let potentialItemId = notification["potentialItem"]
                let postKey = notification["postKey"]
                print("postKey: \(postKey!)")
                
                self.getNotificationItem(itemId: currentItemId!, completion: { (currentItem) in
                    
                    self.getNotificationItem(itemId: potentialItemId!, completion: { (potentialItem) in
                        
                        let newNotification = ["currentItem":currentItem,
                                               "potentialItem":potentialItem,
                                               "postKey":postKey!] as [String : Any]
                        
                        var notificationFound = false
                        
                        for dict in self.userNotifications {
                        
                            if let somePostKey = dict["postKey"] as! String! {
                                
                                if somePostKey == postKey!{
                                    notificationFound = true
                                    break
                                }
                            }
                        }
                        
                        if (!notificationFound){
                            
                            self.userNotifications.append(newNotification)

                        }
                        
                        
                    })
                    
                })
            }
        }
    }
    
    
    
    func getNotifications(completion: @escaping ([String:Any]) -> Void){
        
        let userNotificationRef = ref.database.reference().child("/users/\(sharedUser.firebaseUID!)/notifications")
        
        //get initial notifications
        userNotificationRef.observe(.value, with: { (snapshot) in
            
            if !self.initialDataLoaded{
                
                var notifications = [String:Any]()
                
                for child in snapshot.children{
                    self.newNotification = [String:Any]()
                    
                    let childValue = child as! FIRDataSnapshot
                    
                    let notificationValue = childValue.value as! [String:Any]
                    
                    let currentItemId = notificationValue["currentItem"] as! String
                    let potentialItemId = notificationValue["potentialItem"] as! String
                    
                    let tradeOffer = [
                        "currentItem":currentItemId,
                        "potentialItem":potentialItemId,
                        "postKey":childValue.key
                    ]
                    notifications[childValue.key] = tradeOffer
                }
                completion(notifications)
                self.initialDataLoaded = true
            }
        })
        
        //listen for any new notifications added
        userNotificationRef.observe(.childAdded, with: { (snapshot) in
            
            if self.initialDataLoaded {
                
                var notifications = [String:Any]()
                self.newNotification = [String:Any]()
                
                //self.newNotification["notificationID"] = childValue.key
                
                let notificationValue = snapshot.value as! [String:Any]
                
                let currentItemId = notificationValue["currentItem"] as! String
                let potentialItemId = notificationValue["potentialItem"] as! String
                
                let tradeOffer = [
                    "currentItem":currentItemId,
                    "potentialItem":potentialItemId,
                    "postKey":snapshot.key
                ]
                notifications[snapshot.key] = tradeOffer
                
                completion(notifications)
                
            }
            
        })
        
    }
    
    func getNotificationItem(itemId: String, completion: @escaping (Item) -> Void){
        
        let currentPostRef = self.ref.database.reference().child("/posts/\(itemId)")
        
        currentPostRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let item = Item(snapshot: snapshot)
            completion(item)
        })
    }
    
    
    func getUserTradeCount(userID: String, completion: @escaping (String?) -> Void){
        
        let tradeCountRef = self.ref.database.reference().child("/users/\(userID)/tradeCount")
        
        tradeCountRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let tradeCount = snapshot.value as? String
            
            completion(tradeCount)
        })
        
    }
    
    
    func getItemTradeCount(itemID: String, completion: @escaping (String?) -> Void) {
        
        let itemScoreRef = self.ref.database.reference().child("/posts/\(itemID)/tradeCount")
        
        itemScoreRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let tradeCount = snapshot.value as? String
            
            completion(tradeCount)
        })
    }
    
    func getItemTradeScore(itemID: String, completion: @escaping (String?) -> Void) {
        
        let itemScoreRef = self.ref.database.reference().child("/posts/\(itemID)/tradeScore")
        
        
        itemScoreRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let tradeScore = snapshot.value as? String
            
            completion(tradeScore)
            
        })
    }
    
    
    func acceptTrade(cell: NotificationTableViewCell) {
        
        let indexPath = tableView?.indexPath(for: cell)
        var myItemTradeCount = 0
        var otherItemTradeCount = 0
        var myItemScore = 1
        var otherItemScore = 1
        
        
        //swap item owners, remove notification
        
        let notification = userNotifications[indexPath!.row]
        
        let currentItem = notification["currentItem"] as! Item
        let potentialItem = notification["potentialItem"] as! Item
        
        
        
        getItemTradeCount(itemID: currentItem.postID, completion: { (itemTradeCount) in
            
            if (itemTradeCount != nil) {
                myItemTradeCount = Int(itemTradeCount!)!
                myItemTradeCount += 1
            }
            
            self.getItemTradeCount(itemID: potentialItem.postID, completion: { (itemTradeCount) in
                
                if(itemTradeCount != nil) {
                    otherItemTradeCount = Int(itemTradeCount!)!
                    otherItemTradeCount += 1
                }
                
                
                self.getItemTradeScore(itemID: currentItem.postID, completion: { (itemScore) in
                    
                    if(itemScore != nil){
                        myItemScore = Int(itemScore!)!
                        myItemScore *= 2
                    }
                    
                    self.getItemTradeScore(itemID: potentialItem.postID, completion: { (itemScore) in
                        
                        if(itemScore != nil){
                            otherItemScore = Int(itemScore!)!
                            otherItemScore *= 2
                        }
                        
                        let childUpdates = [
                            
                            "/posts/\(currentItem.postID!)/tradeCount": String(myItemTradeCount) ,
                            "/posts/\(potentialItem.postID!)/tradeCount": String(otherItemTradeCount),
                            
                            
                            "/posts/\(currentItem.postID!)/tradeScore": String(myItemScore),
                            "/posts/\(potentialItem.postID!)/tradeScore": String(otherItemScore),
                            
                            
                            "/posts/\(currentItem.postID!)/author": potentialItem.userID!,
                            "/posts/\(potentialItem.postID!)/author":currentItem.userID!,
                            
                            ]
                        
                        
                        self.ref.updateChildValues(childUpdates)
                        
                        
                        //remove notification from user
                        
//                        let userNotificationRef = self.ref.database.reference().child("/users/\(self.sharedUser.firebaseUID!)/notifications/\(notification["postKey"] as! String)")
//                        
//                        
//                        userNotificationRef.removeValue()

                        
                        self.declineTrade(cell: cell)
                        
                        
                    })
                    
                    
                })
                
            })
            
        })
        
    }
    
    func declineTrade(cell: NotificationTableViewCell) {
        
        let indexPath = tableView?.indexPath(for: cell)
        
        let notification = userNotifications[indexPath!.row]
        
        let userNotificationRef = ref.database.reference().child("/users/\(sharedUser.firebaseUID!)/notifications/\(notification["postKey"] as! String)")
        
        
        userNotificationRef.removeValue()
        userNotifications.remove(at: indexPath!.row)
        tableView.reloadData()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNotifications.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
        
        
        let currentItem = userNotifications[indexPath.row]["currentItem"] as! Item
        let potentialItem = userNotifications[indexPath.row]["potentialItem"] as! Item
        let postKey = userNotifications[indexPath.row]["postKey"] as! String
        
        //let notificationID = notifications[indexPath.row]["notificationID"] as! String
        
        
        cell.currentItemLabel.text = currentItem.description
        cell.newItemLabel.text = potentialItem.description
        cell.delegate = self
        
        return cell
    }
}
