//
//  ItemDetailViewController.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-18.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    var item : Item!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try? imageView.image = UIImage(data: Data(contentsOf: item.localURL!))
        descriptionLabel.text = item.description
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
