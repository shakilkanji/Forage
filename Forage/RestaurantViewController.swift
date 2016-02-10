//
//  RestaurantViewController.swift
//  Forage
//
//  Created by PATRICK PERINI on 1/30/16.
//  Copyright © 2016 atomic. All rights reserved.
//

import UIKit
import CoreLocation

@IBDesignable
class RestaurantViewController: UIViewController {
    // MARK: Properties
    @IBInspectable var labelColor: UIColor!
    @IBInspectable var inactiveLabelColor: UIColor!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var phoneButton: UIButton!
    
    var restaurantDishesVC: RestaurantDishesPageViewController! {
        return self.childViewControllers.flatMap({ $0 as? RestaurantDishesPageViewController }).first
    }
    
    var restaurant: Restaurant!
    var initialDish: Dish?
    var dishes: [Dish] = []
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.contentView.layer.shadowColor = UIColor.blackColor().CGColor
        self.contentView.layer.shadowOpacity = 0.07
        self.contentView.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        self.contentView.layer.shadowRadius = 15.0
        
        self.phoneButton.layer.borderWidth = 2.0
        self.phoneButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.phoneButton.layer.shadowColor = UIColor.blackColor().CGColor
        self.phoneButton.layer.shadowOpacity = 0.07
        self.phoneButton.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        self.phoneButton.layer.shadowRadius = 15.0
        
        self.phoneButton.alpha = self.restaurant.phone != nil ? 1.0 : 0.5
        self.phoneButton.enabled = self.restaurant.phone != nil
        
        self.nameLabel.text = self.restaurant.name
        self.detailsLabel.text = self.restaurant.details
        
        self.restaurant.dishes {
            self.dishes = $0
            if let initialDish = self.initialDish {
                self.dishes = self.dishes.filter { $0.objectId != initialDish.objectId }
                self.dishes.insert(initialDish, atIndex: 0)
            }
            
            self.restaurantDishesVC.dishes = self.dishes
        }
        
        let priceString = NSMutableAttributedString(string: "$$$$")
        priceString.addAttribute(NSForegroundColorAttributeName,
            value: self.labelColor,
            range: NSMakeRange(0, self.restaurant.priceRate))
        priceString.addAttribute(NSForegroundColorAttributeName,
            value: self.inactiveLabelColor,
            range: NSMakeRange(self.restaurant.priceRate, priceString.length - self.restaurant.priceRate))
        self.priceLabel.attributedText = priceString
        
        let location = CLLocation(latitude: self.restaurant.location.latitude,
            longitude: self.restaurant.location.longitude)
        if let distanceM = SharedAppDelegate?.locationManager.location?.distanceFromLocation(location) {
            let distanceMi = (distanceM * 0.000621371)
            self.distanceLabel.text = String(format: "%.2f mi.", distanceMi)
        } else {
            self.distanceLabel.text = "? mi."
        }
    }
    
    // MARK: Responders
    @IBAction func phoneButtonWasPressed(sender: UIButton?) {
        UIApplication.sharedApplication().openURL(NSURL(string: self.restaurant.phone!)!)
    }
    
    @IBAction func tapGestureWasRecognized(sender: UIGestureRecognizer?) {
        self.performSegueWithIdentifier("Unwind",
            sender: nil)
    }
}
