//
//  PostListTableViewController.swift
//  Timeline
//
//  Created by Tyler on 6/21/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreData

class PostListTableViewController: UITableViewController {
    
    var fetchedResultsController: NSFetchedResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFetchedResultsController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as? PostTableViewCell ?? PostTableViewCell()
        
        let post = PostController.sharedController.posts[indexPath.row]
        cell.updateWithPost(post)
        
        return cell
    }
    
    // MARK: - Fetched Results Controller
    func setupFetchedResultsController() {
        
        let request = NSFetchRequest(entityName: "Post")
        let dataSourceDescription = NSSortDescriptor(key: "timestamp", ascending: false)
        
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [dataSourceDescription]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: Stack.sharedStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("Unable to perform fetch request. \(error.localizedDescription)")
        }
        fetchedResultsController?.delegate
    }
    
        // MARK: - Navigation
        
        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            if segue.identifier == "toDetailSegue" {
                if let postDetailVC = segue.destinationViewController as? PostDetailTableViewController,
                    let selectedIndexPath = self.tableView.indexPathForSelectedRow,
                    let post = fetchedResultsController?.objectAtIndexPath(selectedIndexPath) as? Post {
                    
                    postDetailVC.post = post
                }
            }
            // Get the new view controller using segue.destinationViewController.
            // Pass the selected object to the new view controller.
        }
    }



// Fetched Results Controller Delgate Functions
extension PostListTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // Need to signal to your table view that something is going to happen
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
        // Need to signal to your table view that everything is done.
        tableView.endUpdates()
    }

}