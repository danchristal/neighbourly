//
//  TradeListViewController.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-25.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class TradeListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let reuseIdentifier = "tradeListCell"
    var delegate: ItemCollectionViewController? //should change to Item Data Soruce (Manager?) when separating DataSource from CollectionView
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    let padding: CGFloat = 10.0
    
    var itemList = [Item]()
    private var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        collectionView?.backgroundColor = .darkGray
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        collectionView?.setCollectionViewLayout(layout, animated: true)

        collectionView?.delegate = self
        
        let uid = FIRAuth.auth()?.currentUser?.uid
    
        ref = FIRDatabase.database().reference()
        let postRef = ref.database.reference().child("posts")
        
        postRef.queryOrdered(byChild: "author").queryEqual(toValue: uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children{
                let item = Item(snapshot: child as! FIRDataSnapshot)
                self.itemList.insert(item, at: 0)
            }
            DispatchQueue.main.async(execute: {
                self.collectionView?.reloadData()
            })
            
        })

    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TradeListCollectionViewCell
        
        let item = itemList[indexPath.item]
        
        itemCell.loadsImage(urlString: item.imageURL, completion: { (image) in
            itemCell.cellImageView.image = image
            itemCell.spinner?.stopAnimating()
        })
        
        return itemCell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (view.bounds.size.width - padding * 2) / 2, height: (self.view.bounds.size.width - padding * 2) / 2)
    }

     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
     }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.itemToTradeSelected(item: itemList[indexPath.item])
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    
}
