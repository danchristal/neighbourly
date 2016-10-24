//
//  ItemCollectionViewController.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-17.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ItemCollectionViewController: UICollectionViewController {
    //MARK: Properties
    private let reuseIdentifier = "itemCell"
    private var itemList = [Item]()
    private var ref: FIRDatabaseReference!
    private var initialDataLoaded = false
    private var locationManager: LocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get reference to database
        ref = FIRDatabase.database().reference()
        
        //listen for when posts get added
        let postRef = ref.database.reference().child("posts")
        
        //start listening for location
        locationManager = LocationManager.shared
        
        
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
        let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ItemCollectionViewCell
        
        let item = itemList[indexPath.item]
        itemCell.descriptionLabel.text = item.description
        itemCell.imageView.loadImageUsingCacheWithUrlString(urlString: item.imageURL)

        
        return itemCell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "showDetail") {
            
            let paths = self.collectionView?.indexPathsForSelectedItems
            let path = paths?.first
            let detailViewController = segue.destination as! ItemDetailViewController
            detailViewController.item = self.itemList[(path?.item)!]
        }
        
        
    }
    
    
}
