//
//  Restaurant.swift
//  Forage
//
//  Created by PATRICK PERINI on 1/27/16.
//  Copyright © 2016 atomic. All rights reserved.
//

import Parse

class Restaurant: PFObject, PFSubclassing {
    // MARK: Properties
    @NSManaged var location: PFGeoPoint
    @NSManaged var name: String
    @NSManaged var priceRate: Int
    @NSManaged var details: String?
    @NSManaged var phone: String?
    
    // MARK: Class Accessors
    static func parseClassName() -> String {
        return "Restaurant"
    }
}
