//
//  SearchableRecord.swift
//  Timeline
//
//  Created by Tyler on 6/15/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

protocol SearchableRecord {

    func matchesSearchTerm(searchTerm: String) -> Bool

}
