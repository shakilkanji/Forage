//
//  AppDelegate.swift
//  Dive
//
//  Created by PATRICK PERINI on 1/21/16.
//  Copyright © 2016 atomic. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: Properties
    var window: UIWindow?

    // MARK: Lifecycle
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.setApplicationId("S31oUfqQYNeyD1XMR3tWnEAZEHWHRd4AuEgmYduT",
            clientKey: "JXHbhgJuSoDxRhrXwi4BCiQUqMdHrpX6vOYKI6sa")
        Dish.registerSubclass()
        Restaurant.registerSubclass()
        
        return true
    }
}

