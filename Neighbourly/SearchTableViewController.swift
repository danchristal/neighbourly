//
//  SearchTableViewController.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-31.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    private var searchActive = false
    private var ref: FIRDatabaseReference!
    private var searchResults = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        //extendedLayoutIncludesOpaqueBars = true
        
        
        searchBar.delegate = self
        ref = FIRDatabase.database().reference()
        
    }
    
    
    // MARK: - Search Bar delegate
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchText.isEmpty{
            
            ref.child("posts")
                .queryOrdered(byChild: "description")
                .queryStarting(atValue: searchText)
                .queryEnding(atValue: searchText+"\u{f8ff}")
                .observeSingleEvent(of: .value, with: { snapshot in
                    
                    self.searchResults.removeAll()
                    
                    for child in snapshot.children{
                        
                        //create new item and add to array
                        //
                        let item = Item(snapshot: child as! FIRDataSnapshot)
                        self.searchResults.append(item)
                        
                    }
                    
                    self.tableView.reloadData()
                })
        } else {
            searchResults.removeAll()
        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        
        // Configure the cell...
        
        cell.descriptionLabel.text = searchResults[indexPath.row].description
        
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
