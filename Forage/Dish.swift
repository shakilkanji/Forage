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
    
    class func all(callback: ([Dish]) -> Void) {
        self.query(self.query(), callback: callback)
    }
    
    class func near(location: CLLocation, radius: CLLocationDistance, callback: ([Dish]) -> Void) {
        guard radius > Double(FLT_EPSILON) else {
            callback([])
            return
        }
        
        let query = Restaurant.query()
        query?.whereKey("location",
            nearGeoPoint: PFGeoPoint(location: location),
        withinKilometers: radius / 1000.0)
        
        query?.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            guard let restaurants = objects as? [Restaurant] else { callback([]); return }

            let query = Dish.query()
            query?.whereKey("restaurant", containedIn: restaurants)
            self.query(query, callback: callback)
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

extension Dish { // Local Storage
    func saveToShortList() {
        guard let objectId = self.objectId else { return }
        var shortList = NSUserDefaults.standardUserDefaults().objectForKey("ShortList") as? [String] ?? []
        
        shortList.append(objectId)
        NSUserDefaults.standardUserDefaults().setObject(shortList, forKey: "ShortList")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func shortList(callback: ([Dish]) -> Void) {
        guard let shortList = NSUserDefaults.standardUserDefaults().objectForKey("ShortList") as? [String] else { callback([]); return }
        
        let query = self.query()
        query?.whereKey("objectId", containedIn: shortList)
        self.query(query, callback: callback)
    }
}
