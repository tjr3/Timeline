//
//  Comment.swift
//  Timeline
//
//  Created by Tyler on 6/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class Comment: SyncableObject, SearchableRecord {
    
    static let photoDataKey = "photoData"
    static let timestampKey = "timestamp"

    convenience init(post: Post, text: String, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let entity = NSEntityDescription.entityForName("Comment", inManagedObjectContext: context) else { fatalError("Error: Core Data failed to create entity from entity description") }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.text = text
        self.timestamp = timestamp
        self.recordName = NSUUID().UUIDString
        
    }
    
    // MARK: - Searchable Record -
    func matchesSearchTerm(searchTerm: String) -> Bool {
        
        return text?.containsString(searchTerm) ?? false
    }
}