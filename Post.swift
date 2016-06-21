//
//  Post.swift
//  Timeline
//
//  Created by Tyler on 6/21/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class Post: SyncableObject {

    convenience init(photoData: NSData, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context) else {
            fatalError()
        }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.photoData = photoData
        self.timestamp = timestamp
    }
    
    var photo: UIImage? {
        if let photoData = self.photoData {
            return UIImage(data: photoData)
        } else {
            return nil
        }
    }
}

