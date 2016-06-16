//
//  CloudKitManager.swift
//  Timeline
//
//  Created by Tyler on 6/15/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class CloudKitManager {
    
    private let creationDateKey = "creationDate"
    
    let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
    let privateDatabase = CKContainer.defaultContainer().privateCloudDatabase
    
    init() {
        checkCloudKitAvailability()
        requestDiscoverabilityPermission()
    }
    
    // MARK: - User Info Discovery -
    
    // This pulls the record of the current user logged into the app
    func fetchLoggedInUserRecord(completion: ((record: CKRecord?, error: NSError?) -> Void)?) {
        CKContainer.defaultContainer().fetchUserRecordIDWithCompletionHandler { (recordID, error) in
            if let error = error,
                let completion = completion {
                completion(record: nil, error: error)
            }
            
            if let recordID = recordID,
                let completion = completion {
                self.fetchRecordWithID(recordID, completion: { (record, error) in
                    completion(record: record, error: error)
                })
            }
        }
    }
    
    // Go gets the name of the user from the RecordID
    func fetchUsernameFromRecordID(recordID: CKRecordID, completion: ((firstName: String?, lastName: String?) -> Void)?) {
        let operation = CKDiscoverUserInfosOperation(emailAddresses: nil, userRecordIDs: [recordID])
        
        operation.discoverUserInfosCompletionBlock = { (emailsToUserInfos, userRecordIDsToUserInfos, operationError) -> Void
            in
            if let userRecordIDsToUserInfos = userRecordIDsToUserInfos,
                let userInfo = userRecordIDsToUserInfos[recordID],
                let completion = completion {
                completion(firstName: userInfo.displayContact?.givenName, lastName: userInfo.displayContact?.familyName)
            } else if let completion = completion {
                completion(firstName: nil, lastName: nil)
            }
        }
        
        CKContainer.defaultContainer().addOperation(operation)
    }
    
    // Goes and gets all contacts that are discoverable
    func fetchAllDiscoverableUsers(completion: ((userInfoRecords: [CKDiscoveredUserInfo]?) -> Void)?) {
        
        let operation = CKDiscoverAllContactsOperation()
        
        operation.discoverAllContactsCompletionBlock = { (discoveredUserInfos, error) -> Void in
            
            if let completion = completion {
                completion(userInfoRecords: discoveredUserInfos)
            }
        }
        
        CKContainer.defaultContainer().addOperation(operation)
    }
    // MARK: - Fetch Records -
    
    // Takes in a RecordID and returns a record
    func fetchRecordWithID(recordID: CKRecordID, completion: ((record: CKRecord?, error: NSError?) -> Void)?) {
        publicDatabase.fetchRecordWithID(recordID) { (record, error) in // Apple
            if let completion = completion {                            // Ours
                completion(record: record, error: error)
            }
        }
    }
    
    func fetchRecordsWithType(type: String, predicate: NSPredicate = NSPredicate(value: true), recordFetchedBlock: ((record: CKRecord) -> Void)?, completion: ((records: [CKRecord]?, error: NSError?) -> Void)?) {
        
        var fetchedRecords: [CKRecord] = []
        
        let query = CKQuery(recordType: type, predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query) // Block = once the query is done, run the block of code
        
        // This block will run for every record we have in iCloud.
        // Bring back fetched records and adding what ever records were fetched to our array
        queryOperation.recordFetchedBlock = { (fetchedRecord) -> Void in
            fetchedRecords.append(fetchedRecord)
            if let recordFetchedBlock = recordFetchedBlock {
                recordFetchedBlock(record: fetchedRecord)
            }
        }
        // If there is a cursor, it will pull them down until the cursor comes back with nil.
        queryOperation.queryCompletionBlock = { (queryCursor, error) -> Void in
            if let queryCursor = queryCursor {
                let continuedQueryOperation = CKQueryOperation(cursor: queryCursor)
                continuedQueryOperation.recordFetchedBlock = queryOperation.recordFetchedBlock
                continuedQueryOperation.queryCompletionBlock = queryOperation.queryCompletionBlock
                self.publicDatabase.addOperation(continuedQueryOperation)
            } else {
                if let completion = completion {
                    completion(records: fetchedRecords, error: error)
                }
            }
        }
        
        self.publicDatabase.addOperation(queryOperation)
    }
    
    func  fetchCurrentUserRecords(type: String, completion: ((records: [CKRecord]?, error: NSError?) -> Void)?) {
        fetchLoggedInUserRecord { (record, error) in
            // TODO: Handle Error
            if let record = record {
                // Google Predicate Format because it funky
                let predicate = NSPredicate(format: "%K == %@", argumentArray: ["creatorUserRecordID", record.recordID])
                self.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: nil, completion: { (records, error) in
                    // Handel Error
                    if let completion = completion {
                        completion(records: records, error: error)
                    }
                })
            }
        }
    }
    
    func fetchRecordsFromDateRange(type: String, fromDate: NSDate, toDate: NSDate, completion: ((records: [CKRecord]?, error: NSError?) -> Void)?) {
        let startDatePredicate = NSPredicate(format: "%K > %@", argumentArray: [creationDateKey, fromDate])
        let endDatePredicate = NSPredicate(format: "%K < %@", argumentArray: [creationDateKey, toDate])
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startDatePredicate, endDatePredicate])
        
        self.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            if let completion = completion {
                completion(records: records, error: error)
            }
        }
    }
    
    // MARK: - Delete -
    
    func deleteRecordWithID(recordID: CKRecordID, completion: ((recordID: CKRecordID?, error: NSError?) -> Void)?) {
        publicDatabase.deleteRecordWithID(recordID) { (recordID, error) in
            if let completion = completion {
                completion(recordID: recordID, error: error)
            }
        }
    }
    
    func deleteRecordsWithID(recordIDs: [CKRecordID], completion: ((records: [CKRecord]?, recordIDs: [CKRecordID]?, error: NSError?) -> Void)?) {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
        operation.queuePriority = .High
        operation.savePolicy = .IfServerRecordUnchanged
        operation.qualityOfService = .UserInitiated
        operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) -> Void in
            if let completion = completion {
                completion(records: records, recordIDs: recordIDs, error: error)
            }
        }
        
        CKContainer.defaultContainer().addOperation(operation)
    }
    
    // MARK: - Save and Modify -
    
    func saveRecords(records: [CKRecord], perRecordCompletion: ((record: CKRecord?, error: NSError?) -> Void)?, completion: ((records: [CKRecord]?, error: NSError?) -> Void)?) {
        modifyRecords(records, perRecordCompletion: perRecordCompletion) { (records, error) in
            if let completion = completion {
                completion(records: records, error: error)
            }
        }
    }
    
    func saveRecord(record: CKRecord, completion: ((record: CKRecord?, error: NSError?) -> Void)?) {
        publicDatabase.saveRecord(record) { (record, error) in
            if let completion = completion {
                completion(record: record, error: error)
            }
        }
    }
    
    func modifyRecords(records: [CKRecord], perRecordCompletion: ((record: CKRecord?, error: NSError?) -> Void)?, completion: ((records: [CKRecord]?, error: NSError?) -> Void)?) {
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.queuePriority = .High
        operation.savePolicy = .ChangedKeys
        operation.qualityOfService = .UserInteractive
        
        // Saves them individually
        operation.perRecordCompletionBlock = { (record, error) -> Void in
            if let perRecordCompletion = perRecordCompletion {
                perRecordCompletion(record: record, error: error)
            }
        }
        
        // Saves them all
        operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) -> Void in
            if let completion = completion {
                completion(records: records, error: error)
            }
        }
        
        publicDatabase.addOperation(operation)
    }
    
    //MARK: - CloudKit Permissions -
    
    // Error Handeling
    func checkCloudKitAvailability() {
        CKContainer.defaultContainer().accountStatusWithCompletionHandler { (accountStatus: CKAccountStatus, error: NSError?) in
            switch accountStatus {
            case .Available:
                print("CloudKit available")
            default:
                self.handleCloudKitUnavaliable(accountStatus, error: error)
            }
        }
    }
    
    
    // Letting the user know what error occured and where
    func handleCloudKitUnavaliable(accountStatus: CKAccountStatus, error: NSError?) {
        var errorText = "Sync is disabled \n"
        if let error = error {
            errorText += error.localizedDescription
        }
        switch accountStatus {
        case .Restricted:
            errorText += "iCloud is not available due to restrictions"
        case .NoAccount:
            errorText += "There is no iCloud account set up. \n You can setup iCloud in the Settings app"
        default:
            break
        }
        displayCloudKitNotAvaliableError(errorText)
    }
    
    func displayCloudKitNotAvaliableError(errorText: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let alertController = UIAlertController(title: "iCloud Sync Error", message: errorText, preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            
            alertController.addAction(dismissAction)
            
            if let appDelegate = UIApplication.sharedApplication().delegate,
                let appWindow = appDelegate.window!,
                let rootViewController = appWindow.rootViewController {
                rootViewController.presentViewController(alertController, animated: true, completion: nil)
            }
        })
    }
    
    //MARK: - CloudKit Discoverability
    
    func requestDiscoverabilityPermission() {
        CKContainer.defaultContainer().statusForApplicationPermission(.UserDiscoverability) { (permissionStatus, error) in
            if permissionStatus == .InitialState {
                CKContainer.defaultContainer().requestApplicationPermission(.UserDiscoverability, completionHandler: { (permissionStatus, error) in
                    self.handleCloudKitPermissionStatus(permissionStatus, error: error)
                })
            } else {
                self.handleCloudKitPermissionStatus(permissionStatus, error: error)
            }
        }
    }
    
    func handleCloudKitPermissionStatus(permissionStatus: CKApplicationPermissionStatus, error: NSError?) {
        if permissionStatus == .Granted {
            print("User Discoverability permission granted. User may proceed with full access")
        } else {
            var errorText = "Sync is disabled /n"
            if let error = error {
                errorText += error.localizedDescription
            }
            switch permissionStatus {
            case .Denied:
                errorText += "You have denied User Discoverability permissions. You may be unable to use certain features that require User Discoverability."
            case .CouldNotComplete:
                errorText += "Unable to verify User Discoverability permissions. You may have a connectivity issue. Please try again."
            default:
                break
            }
            displayCloudKitPermissionNotGrantedError(errorText)
        }
    }
    
    func displayCloudKitPermissionNotGrantedError(errorText: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let alertController = UIAlertController(title: "CloudKit Permissions Error", message: errorText, preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            
            alertController.addAction(dismissAction)
            
            if let appDelegate = UIApplication.sharedApplication().delegate,
                let appWindow = appDelegate.window!,
                let rootViewController = appWindow.rootViewController {
                rootViewController.presentViewController(alertController, animated: true, completion: nil)
            }
        })
    }
}