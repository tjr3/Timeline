//
//  PostDetailTableViewController.swift
//  Timeline
//
//  Created by Tyler on 6/14/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreData

class PostDetailTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var post: Post?
    
    var fetchedResultsController: NSFetchedResultsController?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var followPostButton: UIBarButtonItem!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        
        if let post = post {
            updateWithPost(post)
        }
        
       setupFetchedResultsController()
    }
    
    func updateWithPost(post: Post) {
        imageView.image = post.photo

    }
    
    // MARK: - FetchedResultsController
    
    func setupFetchedResultsController() {
        
        guard let post = post else { fatalError("Unable to use Post to set up fetched results controller")}
        let request = NSFetchRequest(entityName: "Comment")
//        let predicate = NSPredicate(format: "post == %@", argumentArray: [post])
        let timeSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        
        request.returnsObjectsAsFaults = false
//        request.predicate = predicate
        request.sortDescriptors = [timeSortDescriptor]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: Stack.sharedStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Unable to perform fetch request")
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
    
    @IBAction func commentButtonTapped(sender: AnyObject) {
        
        var commentTextField: UITextField?
        
        let alert = UIAlertController(title: "Add Comment", message: "What do you want to say?", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) in
            textField.placeholder = "Add Comment..."
         commentTextField = textField
        })
        
         let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let addCommentAction = UIAlertAction(title: "Comment", style: .Default) { (_) in
            guard let comment = commentTextField?.text where comment.characters.count > 0
                else { return }
        }
        self.presentViewController(alert, animated: true, completion: nil)
        
        
        alert.addAction(cancelAction)
        alert.addAction(addCommentAction)
        
        presentViewController(alert, animated: true, completion: nil)
        
        
        
    }
    @IBAction func shareButtonTapped(sender: AnyObject) {
    }
    @IBAction func followButtonTapped(sender: AnyObject) {
    }
    
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        default:
            break
        }
    }
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Delete:
            guard let indexPath = indexPath else {return}
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        case .Insert:
            guard let newIndexPath = newIndexPath else {return}
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
        case .Update:
            guard let indexPath = indexPath else {return}
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        case .Move:
            guard let indexPath = indexPath, newIndexPath = newIndexPath else {return}
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
