//
//  PostController.swift
//  Timeline
//
//  Created by Tyler on 6/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import UIKit

class PostController {
    
    static let sharedController = PostController()
    
    
   
    
    func createPost(image: UIImage, caption: String, completion: (() -> Void)?) {
        guard let data = UIImageJPEGRepresentation(image, 0.8) else { return }
        
        let post = Post(photo: data)
        
        addCommentToPost(caption, post: post, completion: nil)
        saveContext()
        
        if let completion = completion {
            completion()
        }
        
    }
    
    func addCommentToPost(text: String, post: Post, completion: ((sucess: Bool) -> Void)?) {
        
        let comment = Comment(post: post, text: text)
        
        saveContext()
        
        if let completion = completion {
            completion(sucess: true)
        }
        
    }
    
    func saveContext() {
        
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Unable to save context: \(error)")
        }
    }
}