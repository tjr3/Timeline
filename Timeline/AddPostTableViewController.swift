//
//  AddPostTableViewController.swift
//  Timeline
//
//  Created by Tyler on 6/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {

    var image: UIImage?
  
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    // MARK: - Action Buttons -
    
    @IBAction func selectImageButtonTapped(sender: AnyObject) {
        imageView.image = UIImage(named: "IMG_5490")
    }
    
    @IBAction func postTapped(sender: AnyObject) {
        if let image = image,
        let caption = captionTextField.text {
            PostController.sharedController.createPost(image, caption: caption, completion: { 
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            
        } else {
 
            let alertController = UIAlertController(title: "Error!", message: "There was a problem uploading your post, check that you have am image and a caption.", preferredStyle: .Alert)
            let postAlert = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            
            presentViewController(alertController, animated: true, completion: nil)
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