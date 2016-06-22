//
//  PostDetailTableViewController.swift
//  Timeline
//
//  Created by Tyler on 6/21/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreData

class PostDetailTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var fetchedResultsController: NSFetchedResultsController?
    
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        setupFetchedResultsController()
    }
    
    func updateWithPost() {
        imageView.image = post?.photo
        tableView.reloadData()
    }
    
    // MARK: - Fetched Results Controller
    
    func setupFetchedResultsController() {
        guard let post = post else { fatalError("Unable to use Post to set up fetched results controller") }
        let request = NSFetchRequest(entityName: "Comment")
        let predicate = NSPredicate(format: "post == %@", argumentArray: [post])
        let dataSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        request.sortDescriptors = [dataSortDescriptor]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: Stack.sharedStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("Unable to perform fetch request. \(error.localizedDescription)")
        }
        fetchedResultsController?.delegate = self
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController?.sections else { return 1 }
        return sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else { return 0 }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath)
        
        if let comment = fetchedResultsController?.objectAtIndexPath(indexPath) as? Comment {
            cell.textLabel?.text = comment.text
        }
        return cell
    }
    
    // MARK: - Action Buttons
    
    @IBAction func followTapped(sender: AnyObject) {
    }
    
    @IBAction func shareTapped(sender: AnyObject) {
        presentActivityController()
    }
    
    @IBAction func commentTapped(sender: AnyObject) {
        presentCommentAlert()
    }
    
    func presentCommentAlert() {
        let alertController = UIAlertController(title: "Add Comment", message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            
        }
        let addCommentAction = UIAlertAction(title: "Add Comment", style: .Default) { (action) in
            guard let commentText = alertController.textFields?.first?.text,
                let post = self.post else {return}
            PostController.sharedController.addCommentToPost(commentText, post: post)
        }
        alertController.addAction(addCommentAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func presentActivityController() {
        
        guard let photo = post?.photo,
            let comment = post?.comments?.firstObject as? Comment,
            let text = comment.text else { return }
        
        let activityViewController = UIActivityViewController(activityItems: [photo, text], applicationActivities: nil)
        
        presentViewController(activityViewController, animated: true, completion: nil)
    }
}