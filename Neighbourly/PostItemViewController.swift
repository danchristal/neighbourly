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


class PostItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    private var picker: UIImagePickerController! { didSet{picker.delegate = self} }
    private var ref: FIRDatabaseReference!
    private var storageRef: FIRStorageReference!
    private var imageURL: String!
    private var locationManager: LocationManager!
    private var postLocation: CLLocation?
    private let placeholderText = "Description: ISO new bicycle wheel"
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var descriptionTextView: UITextView!
        { didSet {descriptionTextView.delegate = self }}
    
    @IBOutlet weak var titleTextField: UITextField!
        { didSet {titleTextField.delegate = self} }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //picker.delegate = self
        //get reference to database
        ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage()
        storageRef = storage.reference(forURL: "gs://neighbourly-deeda.appspot.com")
        
        //Add notifications to show/hide keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(PostItemViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostItemViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    
    func keyboardWillShow(notification: NSNotification) { 

        bottomConstraint.constant = 260
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        
        bottomConstraint.constant = 63
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if descriptionTextView.text == "" || descriptionTextView.text == placeholderText {
            descriptionTextView.text = placeholderText
            descriptionTextView.textColor = .lightGray
        } else {
            descriptionTextView.text = descriptionTextView.text
            descriptionTextView.textColor = .black
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
                                                    "title": self.titleTextField.text!,
                                                    "description": self.descriptionTextView.text!,
                                                    "imageURL" : self.imageURL,
                                                    "location": self.locationLabel.text!,
                                                    "latitude": self.postLocation?.coordinate.latitude ?? nil,
                                                    "longitude": self.postLocation?.coordinate.longitude ?? nil,
                                                    "author": user.firebaseUID!,
                                                    "authorName": user.givenName!,
                                                    "tradeCount": "0",
                                                    "tradeScore": "1",
                                                    "authorImageUrl": user.imageUrl?.absoluteString ?? nil,
                                                ]
            
            let childUpdates = ["/posts/\(key)/": post]
            self.ref.updateChildValues(childUpdates)
        }
        
        presentingViewController?.dismiss(animated: true, completion: nil)
        
        //tabBarController?.selectedIndex = 0
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any] ) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        dismiss(animated: true, completion: nil)
        
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        descriptionTextView.textColor = .black
        
        if descriptionTextView.text == placeholderText {
            descriptionTextView.text = ""
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {

        if(textView.text == "") {
            descriptionTextView.text = placeholderText
            descriptionTextView.textColor = .lightGray
        }
        
    }
    
}
