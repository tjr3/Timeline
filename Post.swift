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
import CloudKit


class Post: SyncableObject, SearchableRecord, CloudKitManagedObject {
        
    
    static let typeKey = "Post"
    static let photoDataKey = "photoData"
    static let timestampKey = "timestamp"
    

    convenience init(photoData: NSData, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context) else { fatalError("Error: Core Data failed to create entity from entity description") }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.photoData = photoData
        self.timestamp = timestamp
        self.recordName = self.nameForManagedObject()
        
    }
    
    var photo: UIImage? {
        if let photoData = self.photoData {
            return UIImage(data: photoData)
        } else {
            return nil
        }
    }
    
    lazy var temporaryPhotoUrl: NSURL = {
        // must write to temporary directory to be able to pass image file path url to CKassit
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = NSURL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.URLByAppendingPathComponent(self.recordName).URLByAppendingPathExtension("jpg")
        self.photoData?.writeToURL(fileURL, atomically: true)
        return fileURL
    }()
    
    // MARK: Searchable Record
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
       
        return (self.comments?.array as? [Comment])? .filter({$0.matchesSearchTerm(searchTerm)}).count > 0
    }
    
    //MARK: CloudKitManagedObject methods
    var recordType: String = "Post"
    
    var cloudKitRecord: CKRecord? { // Inherets from the extention
        let recordID = CKRecordID(recordName: recordName)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        record["timestamp"] = timestamp // These keys "whatever" are from the CloudKit documentation
        record["photoData"] = CKAsset(fileURL: temporaryPhotoUrl)
        return record
    }
    
    convenience required init?(record: CKRecord, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let timestamp = record.creationDate,
            photoData = record["photoData"] as? CKAsset else {
                return nil
        }
        
        guard let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context) else {
            fatalError("ERROR! CoreData failed to create entity from entity description. \(#function)")
        }
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.timestamp = timestamp
        self.photoData = NSData(contentsOfURL: photoData.fileURL)
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
        self.recordName = record.recordID.recordName
    }
    
} //end of class

