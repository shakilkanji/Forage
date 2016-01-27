//
//  PermissionsViewController.swift
//  Dive
//
//  Created by PATRICK PERINI on 1/27/16.
//  Copyright © 2016 atomic. All rights reserved.
//

import UIKit
import CoreLocation

class PermissionsViewController: UIViewController {
    // MARK: Responders
    @IBAction func grantButtonWasPressed(sender: UIButton?) {
        SharedAppDelegate?.locationManager.requestAlwaysAuthorization()
    }
}
