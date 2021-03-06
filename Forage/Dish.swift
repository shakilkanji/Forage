//
//  Dish.swift
//  Forage
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
    
    class func near(location: CLLocation, radius: CLLocationDistance, excludeListed: Bool = false, callback: ([Dish]) -> Void) {
        guard radius > Double(FLT_EPSILON) else {
            callback([])
            return
        }
        
        let params: [NSObject: AnyObject] = [
            "lat": location.coordinate.latitude,
            "lon": location.coordinate.longitude,
            "dist": radius / 1000.0
        ]
        
        PFCloud.callFunctionInBackground("dishesNearLocation", withParameters: params) { (result: AnyObject?, error: NSError?) in
            var dishes: [Dish] = []
            defer { callback(dishes) }
            
            guard let objects = result as? [Dish] else { return }
            dishes = objects
        }
    }
    
    class func loadNear(location: CLLocation, callback: ([Dish]) -> Void) {
        let params = [
            "lat": "\(location.coordinate.latitude)",
            "lon": "\(location.coordinate.longitude)"
        ]
        
        PFCloud.callFunctionInBackground("loadDishesNearLocation", withParameters: params) { (result: AnyObject?, error: NSError?) in
            var newDishes: [Dish] = []
            defer { callback(newDishes) }
            
            guard let dishes = (result as? NSDictionary)?["result"] as? [Dish] else { return }
            newDishes = dishes
        }
    }
    
    private class func query(query: PFQuery?, callback: ([Dish]) -> Void) {
        query?.includeKey("restaurant")
        query?.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            var dishes: [Dish] = []
            defer { callback(dishes) }
            
            guard let results = objects as? [Dish] else { return }
            dishes = results
        }
    }
}

extension Restaurant {
    func dishes(callback: ([Dish]) -> Void) {
        let query = Dish.query()
        query?.whereKey("restaurant", equalTo: self)
        Dish.query(query, callback: callback)
    }
}
