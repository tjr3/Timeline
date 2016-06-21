//
//  PostTableViewCell.swift
//  Timeline
//
//  Created by Tyler on 6/21/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    
    var post = Post()
    
    func updateWithPost(post: Post) {
        self.imageView?.image = post.photo
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
 
   


}

