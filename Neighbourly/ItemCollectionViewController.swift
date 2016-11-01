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
import FirebaseStorage

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
    private var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    private var postRef: FIRDatabaseReference!
    private var initialDataLoaded = false
    private var locationManager: LocationManager!
    
    private var desiredItem:Item!
    private var offeredItem:Item!
    
    private var childAddedHandle: UInt!
    private var valueHandle: UInt!
    private var childChangedHandle: UInt!
    private var childRemovedHandle: UInt!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //listen for when posts get added
        postRef = ref.database.reference().child("posts")
        
        
        //start listening for location
        locationManager = LocationManager.shared
        
        
        //FIRMessaging.messaging().subscribe(toTopic: "/topics/all")
        
        
        //handle new posts since initial load
        childAddedHandle = postRef.observe(.childAdded, with: { (snapshot) in
            if self.initialDataLoaded{
                let item = Item(snapshot: snapshot)
                if !self.itemList.contains(item){
                    self.itemList.insert(item, at: 0)
                    DispatchQueue.main.async {
                        self.collectionView?.insertItems(at:  [IndexPath(item: 0, section: 0)] )
                    }
                }
            }
        })
        
        //handle initial data from Firebase
        valueHandle = postRef.observe(.value, with: { (snapshot) in
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
        
        childChangedHandle = postRef.observe(.childChanged, with: {(snapshot) in
            
            let item = Item(snapshot: snapshot)
            let index = self.itemList.index { $0.postID == item.postID }
            self.itemList.remove(at: index!)
            self.itemList.insert(item, at: index!)
            
            DispatchQueue.main.async {
                
                self.collectionView?.reloadItems(at: [IndexPath(item: index!, section: 0)])
                
            }
            
        })
        
        childRemovedHandle = postRef.observe(.childRemoved, with: {(snapshot) in
            
            let item = Item(snapshot: snapshot)
            let index = self.itemList.index{ $0.postID == item.postID }
            self.itemList.remove(at: index!)
            
            print("snapshot has \(snapshot.childrenCount) children")
            
            let storageRef = FIRStorage.storage().reference().child("/\(item.postID!).jpg")
            storageRef.delete(completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
            
            DispatchQueue.main.async {
                self.collectionView?.deleteItems(at:  [IndexPath(item: index!, section: 0)] )
                
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
            itemCell.cellImageView.image = image
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
        
        getUserTokenAndName(uid: newItem.userID, completion: { (token, name) in
            
            print("token from firebase: \(token)")
            
            
            self.ref.updateChildValues(notificationUpdates)
            
            
            //send push notification to newItem owner
            
            let headers: HTTPHeaders = [
                "Authorization": "key=AIzaSyBPRqwey2B-KRiDN6_jK3JZPSA43Of7f4U",
                "Content-Type": "application/json"
            ]
            let notification: [String:String] = [
                "title":"Trade Request",
                "text":"\(name) has requested a trade from you",
                "sound":"default",
                "badge": "1"
            ]
            let parameters: [String:Any] = ["notification":notification,
                                            "project_id":"com.kidsmoke.Neighbourly",
                                            "to":token,
                                            "priority":"high",
                                            ]
            
            let _ = Alamofire.request("https://fcm.googleapis.com/fcm/send", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            
        })
    }
    
    
    func getUserTokenAndName(uid: String, completion: @escaping (String, String) -> Void){
        
        let userRef = self.ref.database.reference().child("users")
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild(uid){
                
                let user = snapshot.childSnapshot(forPath: uid).value as! [String:Any]
                
                let userToken = user["token"] as! String
                let userName = user["givenName"] as! String
                
                DispatchQueue.main.async {
                    completion(userToken, userName)
                }
                
            }
            
        })
        
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
