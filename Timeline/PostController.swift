//
//  PostController.swift
//  Timeline
//
//  Created by Tyler on 6/21/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreData

class PostController {
    
    var posts: [Post] = []
    
    
    static let sharedController = PostController()
    
    // MARK: Model Signatures; CRUD
    
    func saveContext() {
        let moc = Stack.sharedStack.managedObjectContext
        do {
            try moc.save()
        } catch let error as NSError {
            NSLog(error.localizedDescription)
            NSLog("There was an error saving the context")
        }
    }
    
    func createPost(image: UIImage, caption: String) {
        guard let photoData = UIImageJPEGRepresentation(image, 0.8) else {
            return
        }
        let post = Post(photoData: photoData)
        addCommentToPost(caption, post: post)
        saveContext()
    }
    
  
    
    func addCommentToPost(text: String, post: Post) {
     let comment = Comment(post: post, text: text)
        saveContext()
    }
    
    
}