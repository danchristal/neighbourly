//
//  ItemCollectionViewController.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-17.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseMessaging
import FirebaseAuth
import Alamofire

protocol TradeForItemProtocol {
    func tradeButtonPressed(cell: ItemCollectionViewCell, sender: UIButton)
}

protocol ItemToTradeProtocol {
    func itemToTradeSelected(item: Item)
}

class ItemCollectionViewController: UICollectionViewController, UIPopoverPresentationControllerDelegate, TradeForItemProtocol, ItemToTradeProtocol {
    
    //MARK: Properties
    private let reuseIdentifier = "itemCell"
    private var itemList = [Item]()
    private var ref: FIRDatabaseReference!
    private var initialDataLoaded = false
    private var locationManager: LocationManager!
    
    private var desiredItem:Item!
    private var offeredItem:Item!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get reference to database
        ref = FIRDatabase.database().reference()
        
        //listen for when posts get added
        let postRef = ref.database.reference().child("posts")
        
        //start listening for location
        locationManager = LocationManager.shared
        
        
        FIRMessaging.messaging().subscribe(toTopic: "/topics/all")
        
        //handle new posts since initial load
        postRef.observe(.childAdded, with: { (snapshot) in
            if self.initialDataLoaded{
                let item = Item(snapshot: snapshot)
                self.itemList.insert(item, at: 0)
                self.collectionView?.insertItems(at:  [IndexPath(item: 0, section: 0)] )
            }
        })
        
        //handle initial data from Firebase
        postRef.observe(.value, with: { (snapshot) in
            if !self.initialDataLoaded {
                for child in snapshot.children {
                    let item = Item(snapshot: child as! FIRDataSnapshot)
                    self.itemList.insert(item, at: 0)
                }
                
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                })
                self.initialDataLoaded = true
            }
        })
        
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return itemList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ItemCollectionViewCell
        
        let item = itemList[indexPath.item]
        itemCell.descriptionLabel.text = item.description
       // itemCell.imageView.loadImageOnCell(urlString: item.imageURL)
        itemCell.loadsImage(urlString: item.imageURL, completion: { (image) in
            itemCell.imageView.image = image
        })

        itemCell.delegate = self

        
        return itemCell
    }
    
    func tradeButtonPressed(cell: ItemCollectionViewCell, sender: UIButton) {

        //present list of all users items OR present message window
        
        let indexPath = collectionView!.indexPath(for: cell)!
        desiredItem = itemList[indexPath.item]
        print(desiredItem.description)

        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        guard let tradeViewController = storyboard.instantiateViewController(withIdentifier: "tradeList") as? TradeListViewController else{return}
        tradeViewController.modalPresentationStyle = .popover
        tradeViewController.popoverPresentationController?.delegate = self
        tradeViewController.delegate = self
        tradeViewController.popoverPresentationController?.sourceView = sender
        tradeViewController.preferredContentSize = CGSize(width: 300, height: 300)

        present(tradeViewController, animated: true, completion: nil)

    }
    
    func itemToTradeSelected(item: Item){
        sendTradeOffer(for: desiredItem, with: item)
    }
    
    func sendTradeOffer(for newItem: Item, with currentItem: Item){
        //set both items to pending trade

        guard newItem.postID! != currentItem.postID! else {return}
        
        let childUpdates = [
            "/posts/\(currentItem.postID!)/tradePending": newItem.postID!,
            "/posts/\(newItem.postID!)/tradePending":currentItem.postID!
        ]
        ref.updateChildValues(childUpdates)
        
        //create notification and add to list
        
        let tradeOffer = [
                            "currentItem":newItem.postID,
                            "potentialItem":currentItem.postID
        ]

        
        let key = ref.child("posts").childByAutoId().key
        
        let notificationUpdates = [
            "/users/\(newItem.userID!)/notifications/\(key)": tradeOffer
        ]
        
        ref.updateChildValues(notificationUpdates)
        
        
        //send push notification to newItem owner
        
        let headers: HTTPHeaders = [
            "Authorization": "key=AIzaSyBPRqwey2B-KRiDN6_jK3JZPSA43Of7f4U",
            "Content-Type": "application/json"
        ]
        let notification: [String:String] = [
                                                "title":"Trade Request",
                                                "text":"User has requested a trade from you",
                                                "sound":"default",
                                                "badge": "1"
                                                ]
        let parameters: [String:Any] = ["notification":notification,
                                        "project_id":"com.kidsmoke.Neighbourly",
                                        "to":"cCydfBcMkeA:APA91bGnVqMS77vHevyWnyoDhW9kjEij653796ckxjOEGh96QUK9UeOcuwGcctuW3LtkGIVDAsG0VMQyBs8XGnpEdfIYANfyLJ3L2HHYqM0iAwSv5Rp9RbsR0MygtSVbtJz9G1G-zT4o",
                                            "priority":"high",
                                            
                                        ]
        
        let _ = Alamofire.request("https://fcm.googleapis.com/fcm/send", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        
        
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            let paths = self.collectionView?.indexPathsForSelectedItems
            let path = paths?.first
            let detailViewController = segue.destination as! ItemDetailViewController
            detailViewController.item = self.itemList[(path?.item)!]
        }
    }
    
    
}
