//
//  AppDelegate.swift
//  Dive
//
//  Created by PATRICK PERINI on 1/21/16.
//  Copyright © 2016 atomic. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

var SharedAppDelegate: AppDelegate?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: Properties
    var window: UIWindow?
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest        
        return manager
    }()

    // MARK: Lifecycle
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.setApplicationId("S31oUfqQYNeyD1XMR3tWnEAZEHWHRd4AuEgmYduT",
            clientKey: "JXHbhgJuSoDxRhrXwi4BCiQUqMdHrpX6vOYKI6sa")
        Dish.registerSubclass()
        Restaurant.registerSubclass()
        
        SharedAppDelegate = self
        return true
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        guard let restaurantFeedVC = (self.window?.rootViewController as? UINavigationController)?.topViewController as? RestaurantFeedViewController else { return }
        restaurantFeedVC.updateState()
        self.locationManager.startUpdatingLocation()
    }
}

