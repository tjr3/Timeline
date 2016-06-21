//
//  AddPostTableViewController.swift
//  Timeline
//
//  Created by Tyler on 6/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import MessageUI

class AddPostTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var image: UIImage?
    
    
   override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Outlets -
    
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectImage: UIButton!
    
    // MARK: - Action Buttons -
    
    @IBAction func selectImageButtonTapped(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let actionSheet = UIAlertController(title: "Upload Photo", message: "Please Choose a Source", preferredStyle: .ActionSheet)
        self.selectImage.setTitle("", forState: .Normal)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .Default) { (_) in
            imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .Default) { (_) in
            imagePicker.sourceType = .Camera
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
        actionSheet.addAction(cancelAction)
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            actionSheet.addAction(photoLibraryAction)}
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            actionSheet.addAction(cameraAction)}
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        self.imageView.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func postTapped(sender: AnyObject) {
        if let image = imageView.image,
        let caption = captionTextField.text {
            PostController.sharedController.createPost(image, caption: caption, completion: {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            
        } else {
 
            let alertAction = UIAlertController(title: "Error!", message: "There was a problem uploading your post, check that you have am image and a caption.", preferredStyle: .Alert)
            let postAlert = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertAction.addAction(postAlert)
            presentViewController(alertAction, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}


extension AddPostTableViewController: PhotoSelectViewControllerDelegate {
    func photoSelectViewControllerSelected(image: UIImage) {
        self.image = image
    }
}