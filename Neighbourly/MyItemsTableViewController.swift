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

        let uid = FIRAuth.auth()?.currentUser?.uid
        
        ref = FIRDatabase.database().reference()
        let postRef = ref.database.reference().child("posts")
        
        postRef.queryOrdered(byChild: uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children{
                let item = Item(snapshot: child as! FIRDataSnapshot)
                self.myItemList.insert(item, at: 0)
            }
            DispatchQueue.main.async(execute: {
                self.tableView?.reloadData()
            })
            
        })

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
        
        itemCell.loadsImage(urlString: item.imageURL, completion: { (image) in
            itemCell.cellImageView.image = image
        })
        
        return itemCell
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
