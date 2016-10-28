//
//  NotificationViewController.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-27.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit
import FirebaseDatabase


class NotificationViewController: UITableViewController {
    
    var notifications = [[String:Any]]() {
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
        
        //get reference to database
        ref = FIRDatabase.database().reference()
        
        
        
        //handle new posts since initial load
        //        userNotificationRef.observe(.childAdded, with: { (snapshot) in
        //
        //            if self.initialDataLoaded{
        //
        //                self.newNotification = [String:Any]()
        //
        //                let snapshotValue = snapshot.value as! [String:Any]
        //                self.newNotification["notificationID"] = snapshot.key
        //
        //                let currentItemId = snapshotValue["currentItem"] as! String
        //                let potentialItemId = snapshotValue["potentialItem"] as! String
        //
        //                let currentPostRef = self.ref.database.reference().child("/posts/\(currentItemId)")
        //                currentPostRef.observe(.value, with: { (snapshot) in
        //                    let item = Item(snapshot: snapshot)
        //                    self.newNotification["currentItem"] = item
        //
        //                    let potentialPostRef = self.ref.database.reference().child("/posts/\(potentialItemId)")
        //                    potentialPostRef.observe(.value, with: { (snapshot) in
        //                        let item = Item(snapshot: snapshot)
        //                        self.newNotification["potentialItem"] = item
        //
        //                        self.notifications.append(self.newNotification)
        //                    })
        //                })
        //
        //            }
        //        })
        
        //handle initial data from Firebase
        
        //listen for when posts get added
        
        
        getNotifications { (notifications) in

            var notificationDict = notifications
            
            while(!notificationDict.isEmpty){
                let notification = notificationDict.popFirst()
                let notificationItems = notification?.value as! [String:String]
                
                let currentItemId = notificationItems["currentItem"]
                let potentialItemId = notificationItems["potentialItem"]
                
                print("current Item: \(currentItemId!)")
                print("potential Item: \(potentialItemId!)")
                
                self.getNotificationItem(itemId: currentItemId!, completion: { (currentItem) in
                    
                    self.getNotificationItem(itemId: potentialItemId!, completion: { (potentialItem) in
                        
                        let newNotification = ["currentItem":currentItem,
                                               "potentialItem":potentialItem]
                        self.notifications.append(newNotification)
                        
                    })
                    
                })
                
                
            }
        }
        
        
                    
//                    let currentPostRef = self.ref.database.reference().child("/posts/\(currentItemId)")
//                    
//                    
//                    currentPostRef.observe(.value, with: { (snapshot) in
//                        
//                        
//                        let item1 = Item(snapshot: snapshot )
//                        self.newNotification["currentItem"] = item1
//                        
//                        
//                        let potentialPostRef = self.ref.database.reference().child("/posts/\(potentialItemId)")
//                        potentialPostRef.observe(.value, with: { (snapshot) in
//                            
//                            let item2 = Item(snapshot: snapshot)
//                            
//                            self.newNotification["potentialItem"] = item2
//                            self.notifications.append(self.newNotification)
//                            
//                        })
//                        
//                    })
    }
    
    
    func getNotificationItem(itemId: String, completion: @escaping (Item) -> Void){
        
        let currentPostRef = self.ref.database.reference().child("/posts/\(itemId)")

        currentPostRef.observe(.value, with: { (snapshot) in

            let item = Item(snapshot: snapshot )
            completion(item)
//            self.newNotification["currentItem"] = item1
        })
    }
    
    func getNotifications(completion: @escaping ([String:Any]) -> Void){
    
        let userNotificationRef = ref.database.reference().child("/users/\(sharedUser.firebaseUID!)/notifications")

        userNotificationRef.observe(.value, with: { (snapshot) in
            
            if !self.initialDataLoaded{
                
                print(snapshot.children)
                var notifications = [String:Any]()
                
                for child in snapshot.children{
                    self.newNotification = [String:Any]()
                    
                    let childValue = child as! FIRDataSnapshot
                    //self.newNotification["notificationID"] = childValue.key
                    
                    let notificationValue = childValue.value as! [String:Any]
                    
                    let currentItemId = notificationValue["currentItem"] as! String
                    let potentialItemId = notificationValue["potentialItem"] as! String

                    let tradeOffer = [
                        "currentItem":currentItemId,
                        "potentialItem":potentialItemId
                    ]
                    notifications[childValue.key] = tradeOffer
                }
                completion(notifications)
                self.initialDataLoaded = true
            }
            
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
        
        
        let currentItem = notifications[indexPath.row]["currentItem"] as! Item
        let potentialItem = notifications[indexPath.row]["potentialItem"] as! Item
        //let notificationID = notifications[indexPath.row]["notificationID"] as! String
        
        //print("notification ID: \(notificationID)")
        
        
        cell.textLabel?.text = currentItem.description
        cell.detailTextLabel?.text = potentialItem.description

        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
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
