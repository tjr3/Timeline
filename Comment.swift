//
//  Comment.swift
//  Timeline
//
//  Created by Tyler on 6/21/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData


class Comment: SyncableObject {
    
    convenience init(post: Post, text: String, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("Comment", inManagedObjectContext: context) else {
            fatalError()
        }
        self.init(entity: entity, insertIntoManagedObjectContext: context)
            self.text = text
            self.post = post
            self.timestamp = timestamp
            self.recordName = NSUUID().UUIDString
        }
    }
