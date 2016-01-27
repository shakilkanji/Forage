//
//  Dish.swift
//  Dive
//
//  Created by PATRICK PERINI on 1/27/16.
//  Copyright © 2016 atomic. All rights reserved.
//

import Parse

class Dish: PFObject, PFSubclassing {
    // MARK: Properties
    @NSManaged var photo: String
    @NSManaged var restaurant: Restaurant

    // MARK: Class Accessors
    static func parseClassName() -> String {
        return "Dish"
    }
    
    class func all(callback: ([Dish]) -> Void) {
        let query = self.query()
        query?.includeKey("restaurant")
        
        query?.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            var dishes: [Dish] = []
            defer { callback(dishes) }
            
            guard let results = objects as? [Dish] else { return }
            dishes = results
        }
    }
}
