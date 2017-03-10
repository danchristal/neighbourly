//
//  MyItemsTableViewController.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-31.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MyItemsTableViewController: UITableViewController {

    
    private var ref: FIRDatabaseReference!
    private var myItemList = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "My Items"

        let uid = FIRAuth.auth()?.currentUser?.uid
        
        ref = FIRDatabase.database().reference()
        let postRef = ref.database.reference().child("posts")
        
        tableView.separatorStyle = .none
        
        postRef.queryOrdered(byChild: "author").queryEqual(toValue: uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children{
                let item = Item(snapshot: child as! FIRDataSnapshot)
                self.myItemList.insert(item, at: 0)
            }
            DispatchQueue.main.async(execute: {
                self.tableView?.reloadData()
            })
            
        })

    }

    func deleteItem(indexPath: IndexPath){
        
        let item = myItemList[indexPath.row]
        
        
        let itemToDeleteRef = ref.database.reference().child("/posts/\(item.postID)")
        
        itemToDeleteRef.removeValue()
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        myItemList.remove(at: indexPath.row)
        tableView.endUpdates()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return myItemList.count
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var itemCell = tableView.dequeueReusableCell(withIdentifier: "myItemCell", for: indexPath) as! MyItemsTableViewCell
        
        let item = myItemList[indexPath.row]
        
        itemCell.cellTitleLabel.text = item.title
        
        itemCell.loadsImage(urlString: item.imageURL, completion: { (image) in
            itemCell.cellImageView.image = image
        })
        
        return itemCell
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            //let cell = tableView.cellForRow(at: index) as! NotificationTableViewCell
            DispatchQueue.main.async {
                self.deleteItem(indexPath: index)
            }
        }
        delete.backgroundColor = .red
        
        return [delete]
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    

    
}
