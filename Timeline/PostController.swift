//
//  PostController.swift
//  Timeline
//
//  Created by Tyler on 6/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import CoreData
import UIKit

class PostController {
    
    var posts: [Post] {
        
        let fetchRequest = NSFetchRequest(entityName:"Post")
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let results = (try? Stack.sharedStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [Post] ?? []
        
        return results
    }
    
    static let sharedController = PostController()
    
    
    // CRUD:
    func saveContext() {
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Unable to save context: \(error)")
        }
    }
    
    func createPost(image: UIImage, caption: String, completion: (() -> Void)?) {
        guard let photoData = UIImageJPEGRepresentation(image, 0.8) else { return }
        let post = Post(photoData: photoData)
        addCommentToPost(caption, post: post)
        saveContext()
        
        if let cloudKitRecord = post.cloudKitRecord {
            cloudKitManager.saveRecord(cloudKitRecord) { (record, error) in
                if let error = error {
                    NSLog("Error saving cloudkit record for new post \(post): \(error)")
                    return
                }
                guard let record = record else { return }
                post.update(record)
            }
        }
        
        if let completion = completion {
            completion()
        }
    }
    
    func addCommentToPost(text: String, post: Post) {
        let comment = Comment(post: post, text: text)
        saveContext()
        
        if let cloudKitRecord = comment.cloudKitRecord {
            cloudKitManager.saveRecord(cloudKitRecord) { (record, error) in
                if let error = error {
                    NSLog("Error saving cloudkit record for new comment \(comment): \(error)")
                    return
                }
                guard let record = record else { return }
                comment.update(record)
            }
        }
    }
    //MARK: TODO - Make my ish non-optional once i add the syncable object
    
    
    //MARK: - Helper Functions declared for CloudKit
    
    func postWithName(name: String) -> Post? {
        if name.isEmpty {
            return nil
        }
        let fetchRequest = NSFetchRequest(entityName:  "Post")
        let predicate = NSPredicate(format: "recordName == %@", argumentArray: [name])
        fetchRequest.predicate = predicate
        let result = (try? Stack.sharedStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [Post] ?? nil
        return result?.first
    }
    
    func syncedRecords(type: String) -> [CloudKitManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: type)
        fetchRequest.predicate = NSPredicate(format: "recordIDData != nil") // Predicate is basically a test, for the functions to continue it has to pass the test. Checks every object to see if it passed
        
        let moc = Stack.sharedStack.managedObjectContext
        let results = (try? moc.executeFetchRequest(fetchRequest)) as? [CloudKitManagedObject] ?? []
        return results
    }
    
    func unsyncedRecords(type: String) -> [CloudKitManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: type)
        fetchRequest.predicate = NSPredicate(format: "recordIDData == nil") // Predicate is basically a test, for the functions to continue it has to pass the test. Checks every object to see if it passed
        
        let moc = Stack.sharedStack.managedObjectContext
        let results = (try? moc.executeFetchRequest(fetchRequest)) as? [CloudKitManagedObject] ?? []
        return results
    }
    
    func fetchedNewRecords(type: String, completion: (() -> Void)?) {
        let referencesToExclude = syncedRecords(type).flatMap { $0.cloudKitReference }
        let predicate: NSPredicate
        if !referencesToExclude.isEmpty {
            predicate = NSPredicate(format: "NOT(recordID IN %@)", referencesToExclude) //%@ - variable substitution. There is gonnabe a variable there, XCode at run time replace the token with a variable.
        } else {
            predicate = NSPredicate(value: true)
        }
        
        cloudKitManager.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: { (record) in
            switch type {
            case "Post": // these should have a keys for them, out of laziness we hard delcared them
                let _ = Post(record: record)
            case "Comment":
                let _ = Comment(record: record)
            default:
                return
            }
            self.saveContext()
        }) { (records, error) in
            if let error = error {
                NSLog("Error fetching new records from CloudKit: \(error)")
            }
            
            completion?()
        }
    }
    
    func pushChangesToCloudKit(completion: ((success: Bool, error: NSError?) -> Void)? = nil) {
        let unsavedManagedObjects = unsyncedRecords(Post.typeKey) + unsyncedRecords(Comment.typeKey)
        let unsavedRecords = unsavedManagedObjects.flatMap { $0.cloudKitRecord }
        
        cloudKitManager.saveRecords(unsavedRecords, perRecordCompletion: { (record, error) in
            guard let record = record else { return }
            
            if let matchingManagedObject = unsavedManagedObjects.filter({$0.recordName == record.recordID.recordName}).first {
                matchingManagedObject.update(record)
            }
            
        }) { (records, error) in
            let success = records != nil
            completion?(success: success, error: error)
        }
    }
    
    private var isSyncing = false
    func performFullSync(completion: (() -> Void)? = nil) {
        if isSyncing {
            completion?()
            return
        }

        isSyncing = true
        pushChangesToCloudKit { (success) in
            self.fetchedNewRecords(Post.typeKey) {
                self.fetchedNewRecords(Comment.typeKey) {
                    completion?()
                    self.isSyncing = false
                }
            }
        }
    }
    
    let cloudKitManager = CloudKitManager()
}




