//
//  Comment.swift
//  Timeline
//
//  Created by Tyler on 6/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData
import CloudKit


class Comment: SyncableObject, SearchableRecord, CloudKitManagedObject {
    
    static let typeKey = "Comment"
    
    static let photoDataKey = "photoData"
    static let timestampKey = "timestamp"
    
    convenience init(post: Post, text: String, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let entity = NSEntityDescription.entityForName("Comment", inManagedObjectContext: context) else { fatalError("Error: Core Data failed to create entity from entity description") }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.text = text
        self.comments = post
        self.timestamp = timestamp
        self.recordName = NSUUID().UUIDString
        
    }
    
    // MARK: - Searchable Record -
    func matchesSearchTerm(searchTerm: String) -> Bool {
        
        return text?.containsString(searchTerm) ?? false
    }
    
    // MARK: - CloudKitManagedObject Methods
    // taking NSData and turing it into CKRecords, vice versa. 
    
    var recordType: String = "Comment"
    
    var cloudKitRecord: CKRecord? {
        let recordID = CKRecordID(recordName: recordName)
        let record = CKRecord(recordType: recordType,recordID: recordID)
        
        record["text"] = text
        record["timestamp"] = timestamp
        
        guard let post = comments,
            postRecord = post.cloudKitRecord else {
                fatalError("Comment does not have a Post relationship. \(#function)")
        }
        record["post"] = CKReference(record: postRecord, action: .DeleteSelf)
        return record
    }
    
    convenience required init?(record: CKRecord, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext)
    {
        guard let timestamp = record.creationDate,
            text = record["text"] as? String,
            postReference = record["post"] as? CKReference else {
                return nil
        }
        
        guard let entity = NSEntityDescription.entityForName("Comment", inManagedObjectContext: context) else {
            fatalError("Error: CoreData failed to create entity from entity description. \(#function)")
        }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.timestamp = timestamp
        self.text = text
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
        
        // TODO: set value for self.post using postReference.
        
        if let post = PostController.sharedController.postWithName(postReference.recordID.recordName) {
            self.comments = post
        }
    }
    
}




