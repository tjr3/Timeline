//
//  CloudKitManagedObject.swift
//  Timeline
//
//  Created by Tyler on 6/17/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

@objc protocol CloudKitManagedObject {
  
    var timestamp: NSDate { get set } // date and time the object was created
    var recordIDData: NSData? { get set } // persisted CKRecordID
    var recordName: String { get set } // unique name for the object
    var recordType: String { get } // a consistent type string, 'Post' for Post, 'Comment' for Comment
    
    var cloudKitRecord: CKRecord? { get } // CoreData version of dictionaryCopy
    
    init?(record: CKRecord, context: NSManagedObjectContext) // to initialize a new `NSManagedObject` from a `CKRecord` from CloudKit (similar to `init?(json: [String: AnyObject])` when working with REST APIs)
}

extension CloudKitManagedObject {
    
    // helper variable to determine if a CloudKitManagedObject has a CKRecordID, which we can use to say that the record has been saved to the server
    var isSynced: Bool {
        return recordIDData != nil
        }
    
    // a computed property that unwraps the persisted recordIDData into a CKRecordID, or returns nil if there isn't one
    var cloudKitRecordID: CKRecordID? {
        guard let recordIDData = recordIDData,
            // Serizlizing the Data
            recordID = NSKeyedUnarchiver.unarchiveObjectWithData(recordIDData) as? CKRecordID else {
                return nil
        }
        return recordID
    }
    
    // a computed property that returns a CKReference to the object in CloudKit
    var cloudKitReference: CKReference? {
        guard let recordID = cloudKitRecordID else {
            return nil
        }
        return CKReference(recordID: recordID, action: .None)
    }
    
    // called after saving the object, saved the record.recordID to the recordIDData
    func update(record: CKRecord) {
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
        do {
            try Stack.sharedStack.managedObjectContext.save() //This line saves the post in CoreData
        } catch {
            print("Unable to save Managed Object Context in \(#function) \nError: \(error)")
        }
    }
    
    func nameForManagedObject() -> String {
        return NSUUID().UUIDString
    }

}
