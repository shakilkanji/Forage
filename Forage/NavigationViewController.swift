//
//  NavigationViewController.swift
//  Forage
//
//  Created by PATRICK PERINI on 1/31/16.
//  Copyright © 2016 atomic. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {
    // MARK: Accessors
    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue? {
        switch fromViewController {
        case is RestaurantViewController:
            return OverlaySegue.Unwind(identifier: identifier,
                source: toViewController,
                destination: fromViewController,
                performHandler: {})
            
        default:
            return nil
        }
    }
}
