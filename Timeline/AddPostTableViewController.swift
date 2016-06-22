//
//  AddPostTableViewController.swift
//  Timeline
//
//  Created by Tyler on 6/21/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController, UIImagePickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var image: UIImage?
    
        // MARK: - Outlets
    
    @IBOutlet weak var addCaptionTextField: UITextField!
    @IBOutlet weak var selectImageTapped: UIButton!
    @IBOutlet weak var imageView: UIImageView!

        // MARK: - Action Buttons

    @IBAction func selectImageTapped(sender: AnyObject) {
        let image = UIImage(named: "Far Away")
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alert = UIAlertController(title: "Select Photo Location", message: nil, preferredStyle: .ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (_) -> Void in
                im
            })
        }
        
    }
    @IBAction func addPostTapped(sender: AnyObject) {
        if let image = image, let caption = addCaptionTextField.text {
            PostController.sharedController.createPost(image, caption: caption)
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Missing Information", message: "Check that you have an image and caption.", preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(dismissAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
        // MARK: = Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
}
