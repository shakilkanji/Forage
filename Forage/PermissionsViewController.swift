//
//  PermissionsViewController.swift
//  Forage
//
//  Created by PATRICK PERINI on 1/27/16.
//  Copyright © 2016 atomic. All rights reserved.
//

import UIKit
import CoreLocation

class PermissionsViewController: UIViewController {
    // MARK: Responders
    @IBAction func grantButtonWasPressed(sender: UIButton?) {
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined:
            SharedAppDelegate?.locationManager.requestAlwaysAuthorization()
            
        case .Denied, .Restricted:
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            
        default:
            guard let feedVC = self.parentViewController as? RestaurantFeedViewController else { break }
            feedVC.updateState()
        }
    }
}
