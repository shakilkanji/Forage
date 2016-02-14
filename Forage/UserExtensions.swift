//
//  UserExtensions.swift
//  Forage
//
//  Created by PATRICK PERINI on 2/13/16.
//  Copyright © 2016 atomic. All rights reserved.
//

import Parse

extension PFUser {
    // MARK: Properties
    var likedDishes: PFRelation {
        return self.relationForKey("likedDishes")
    }
    
    var dislikedDishes: PFRelation {
        return self.relationForKey("dislikedDishes")
    }
    
    // MARK: Class Accessors
    func matchedRestaurants(callback: ([Restaurant]) -> Void) {
        let likedDishQuery = self.likedDishes.query()
        likedDishQuery.includeKey("restaurant")
        likedDishQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            var restaurants: [Restaurant] = []
            defer { callback(restaurants) }
            
            guard let dishes = objects as? [Dish] else { return }
            restaurants = dishes.map { $0.restaurant }
            
            // Find duplicates
            let ids = Array(Set(restaurants.filter({ (restaurant: Restaurant) in
                restaurants.filter({ $0.objectId == restaurant.objectId }).count > 1
            }).map({ $0.objectId! })))
            
            restaurants = ids.map { (id: String) in
                restaurants.filter { $0.objectId! == id }[0]
            }
        }
    }
    
    func shortList(callback: ([Dish]) -> Void) {
        let likedDishQuery = self.likedDishes.query()
        likedDishQuery.includeKey("restaurant")
        likedDishQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            var restaurants: [Restaurant] = []
            var dishes: [Dish] = []
            
            defer { callback(dishes) }
            
            guard let result = objects as? [Dish] else { return }

            dishes = result
            restaurants = dishes.map { $0.restaurant }
            
            // Find duplicates
            let ids = Array(Set(restaurants.filter({ (restaurant: Restaurant) in
                restaurants.filter({ $0.objectId == restaurant.objectId }).count > 1
            }).map({ $0.objectId! })))
            
            dishes = ids.map { (id: String) in
                dishes.filter { $0.restaurant.objectId! == id }[0]
            }
        }
    }
}
