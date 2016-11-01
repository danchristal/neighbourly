//
//  PostItemViewController.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-17.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import CoreLocation


class PostItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    private var picker: UIImagePickerController! { didSet{picker.delegate = self} }
    private var ref: FIRDatabaseReference!
    private var storageRef: FIRStorageReference!
    private var imageURL: String!
    private var locationManager: LocationManager!
    private var postLocation: CLLocation!
    
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField! { didSet {descriptionTextField.delegate = self} }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //picker.delegate = self
        //get reference to database
        ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage()
        storageRef = storage.reference(forURL: "gs://neighbourly-deeda.appspot.com")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager = LocationManager.shared
        locationImageView.image = #imageLiteral(resourceName: "722-location-pin")
        locationManager.getReverseGeocodeLocation { (location, coordinate) in
            self.locationLabel.text = location
            self.postLocation = coordinate
        }
    }
    
    
    @IBAction func postItemButton(_ sender: UIButton) {
        
        let data = UIImageJPEGRepresentation(imageView.image!, 0.7)!
        let key = ref.child("posts").childByAutoId().key
        
        //let filePath = "\(key)/\("image.png")"
        let filePath = "/\(key).jpg"
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.child(filePath).put(data, metadata: metaData) { (metadata, error) in
            if let error = error{
                print(error.localizedDescription)
            }
            
            //store downloadURL crashes if offline
            self.imageURL = metadata!.downloadURL()!.absoluteString
            
            //self.ref.child("posts").child(key).updateChildValues(["imageURL": self.imageURL])
            
            let user = User.shared
            
            let post: Dictionary<String, Any> = [
                                                    "description": self.descriptionTextField.text!,
                                                    "imageURL" : self.imageURL,
                                                    "location": self.locationLabel.text!,
                                                    "latitude": self.postLocation.coordinate.latitude,
                                                    "longitude": self.postLocation.coordinate.longitude,
                                                    "author": user.firebaseUID!,
                                                    "tradeCount": 1,
                                                    "tradeScore": 0
                                                ]
            
            let childUpdates = ["/posts/\(key)/": post]
            self.ref.updateChildValues(childUpdates)
        }
        tabBarController?.selectedIndex = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func tapImage(_ sender: UITapGestureRecognizer) {
        print("Image tapped")
        
        picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        dismiss(animated: true, completion: nil)
        
    }
    
}
