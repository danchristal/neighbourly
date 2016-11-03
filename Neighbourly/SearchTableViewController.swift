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
    
    private var shouldBeginEditing = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        //extendedLayoutIncludesOpaqueBars = true
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        searchBar.delegate = self
        ref = FIRDatabase.database().reference()
        
    }
    
    
    // MARK: - Search Bar delegate
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        if !searchBar.isFirstResponder {
            shouldBeginEditing = false
        }else if !searchText.isEmpty{
            
            ref.child("posts")
                .queryOrdered(byChild: "description")
                .queryStarting(atValue: searchText)
                .queryEnding(atValue: searchText+"\u{f8ff}")
                .observeSingleEvent(of: .value, with: { snapshot in
                    
                    self.searchResults.removeAll()
                    
                    for child in snapshot.children{

                        let item = Item(snapshot: child as! FIRDataSnapshot)
                        self.searchResults.append(item)
                        
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
        } else {
            searchResults.removeAll()
                self.tableView.reloadData()
            }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        let boolToReturn = shouldBeginEditing
        shouldBeginEditing = true
        return boolToReturn
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchResults.removeAll()
        self.tableView.reloadData()

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
        
        let item = searchResults[indexPath.row]
        
        cell.descriptionLabel.text = item.description
        cell.titleLabel.text = item.title
        cell.itemImageView.loadImage(urlString: item.imageURL)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "searchDetail", sender: self)
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "searchDetail" {
            let indexPath = tableView.indexPathForSelectedRow
            let detailViewController = segue.destination as! ItemDetailViewController
            detailViewController.item = searchResults[(indexPath!.row)]
            
            
        }
    }
    
}
