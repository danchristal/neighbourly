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


class PostItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    private let picker = UIImagePickerController()
    private var ref: FIRDatabaseReference!
    private var storageRef: FIRStorageReference!
    private var imageURL: String!
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        descriptionTextField.delegate = self
        //get reference to database
        ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage()
        storageRef = storage.reference(forURL: "gs://neighbourly-deeda.appspot.com")
    }
    
    @IBAction func postItemButton(_ sender: UIButton) {
        //post to firebase
        
        //post image to firebase storage and get URL
        
        //add url to newPost
        //write newPost to /posts/$postid && /user-posts/$userid/$postid simultaneously
        
        
        let data = UIImageJPEGRepresentation(imageView.image!, 0.8)!
        let key = ref.child("posts").childByAutoId().key
        
        let filePath = "\(key)/\("image.jpg")"
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.child(filePath).put(data, metadata: metaData) { (metaData, error) in
            if let error = error{
                print(error.localizedDescription)
            }
            
            //store downloadURL crashes if offline
            self.imageURL = metaData?.downloadURL()?.absoluteString
            //self.ref.child("posts").child(key).updateChildValues(["imageURL": self.imageURL])
            
            let userID = FIRAuth.auth()?.currentUser?.uid
            
            let post: Dictionary<String, String> = ["description": self.descriptionTextField.text!,
                                                   "imageURL" : self.imageURL,
                                                   "author": userID!]
            
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
        
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        dismiss(animated: true, completion: nil)
        
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
