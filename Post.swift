//
//  Post.swift
//  Timeline
//
//  Created by Tyler on 6/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class Post: SyncableObject, SearchableRecord {
    
    
    static let typeKey = "Post"
    static let photoDataKey = "photoData"
    static let timestampKey = "timestamp"
    

    convenience init(photo: NSData, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context) else { fatalError("Error: Core Data failed to create entity from entity description") }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.photoData = photo
        self.timestamp = timestamp
        
        
    }
    
    var photo: UIImage? {
        
        guard let photoData = self.photoData else { return nil }
        
        return UIImage(data: photoData)
    }
    
    // MARK: Searchable Record
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
       
        return (self.comments?.array as? [Comment])? .filter({$0.matchesSearchTerm(searchTerm)}).count > 0
    }

}
