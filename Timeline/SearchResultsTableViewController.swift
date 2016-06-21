//
//  SearchResultsTableViewController.swift
//  Timeline
//
//  Created by Tyler on 6/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: UITableViewController {
    
    var post: [Post] = []
    
    var resultsArray: [SearchableRecord] = [] // [] means the initial value has nothing, an empty array.
    //     note: For now you will only display Post objects as a result of a search. Use the PostTableViewCell to do so.

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resultsArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("resultCell", forIndexPath: indexPath) as? PostTableViewCell,
        let result = resultsArray[indexPath.row] as? Post else { return UITableViewCell() }
        
        cell.updateWithPost(result)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        self.presentingViewController?.performSegueWithIdentifier("ToPostDetailFromSearch", sender: cell)
    }
}
