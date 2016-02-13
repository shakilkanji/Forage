//
//  RestaurantFeedViewController.swift
//  Forage
//
//  Created by PATRICK PERINI on 1/21/16.
//  Copyright © 2016 atomic. All rights reserved.
//

import UIKit
import ZLSwipeableViewSwift
import AFNetworking
import CoreLocation

@IBDesignable
class RestaurantFeedViewController: UIViewController {
    // MARK: Types
    enum State {
        case Unknown
        case Unauthorized
        case Pending
        case Ready
        case Empty
    }
    
    // MARK: Properties
    @IBOutlet var cardStackView: ZLSwipeableView!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var distanceSlider: UISlider!
    @IBOutlet var permissionsContainerView: UIView!
    @IBOutlet var emptyContainerView: UIView!

    private var cardStackIndex: Int = 0
    private var swipedCardIndex: Int = 0
    
    
    private var dishes: [Dish]? {
        didSet {
            self.updateState()
        }
    }
    
    private var miles: Float {
        return self.distanceSlider.value
    }
    
    private var distance: CLLocationDistance {
        return CLLocationDistance(self.miles * 1609.34)
    }
    
    private var state: State = .Unknown {
        didSet {
            defer {
                if self.state == .Pending {
                    self.reloadData()
                }
            }
            
            guard self.state != oldValue else { return }
            guard let _ = self.viewIfLoaded else { return }
            
            self.cardStackView.hidden = [.Unknown, .Unauthorized].contains(self.state)
            self.permissionsContainerView.hidden = [.Unknown, .Pending, .Ready, .Empty].contains(self.state)
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.distanceSlider.setThumbImage(UIImage(named: "SliderThumb"),
            forState: .Normal)

        self.updateState()
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "initialLocationWasFound:",
            name: AppDelegate.DidFindInitialLocationsNotification,
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Mutators
    func updateState() {
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            self.state = .Unauthorized
        } else if SharedAppDelegate?.locationManager.location == nil || self.dishes == nil {
            self.state = .Pending
        } else if self.swipedCardIndex != (self.dishes!.count - 1) {
            self.state = .Ready
        } else {
            self.state = .Empty
        }
    }
    
    func reloadData(force: Bool = false) {
        guard let location = SharedAppDelegate?.locationManager.location else { return }
        
        Dish.near(location, radius: self.distance, excludeListed: true) {
            self.dishes = $0
            self.reloadDataForSwipeableView(self.cardStackView)
            self.updateState()
            
            // Update on server
            Dish.loadNear(location) { (newDishes: [Dish]) in
                guard let dishes = self.dishes else { return }
                self.dishes = dishes + newDishes
                
                self.reloadDataForSwipeableView(self.cardStackView)
                self.updateState()
            }
        }
    }
    
    // MARK: Responders
    func initialLocationWasFound(notification: NSNotification?) {
        self.updateState()
    }
    
    @IBAction func distanceSlideWasSlid(sender: UISlider?) {
        self.dishes = nil
    }
    
    @IBAction func distanceSliderValueChanged(sender: UISlider?) {
        let formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 2
        
        let miles = formatter.stringFromNumber(NSNumber(float: self.miles))!
        self.distanceLabel.text = "\(miles) mi."
    }
}

extension RestaurantFeedViewController { // SwipeableView Data Source
    func reloadDataForSwipeableView(swipeableView: ZLSwipeableView) {
        self.cardStackView.numberOfActiveView = self.numberOfViewsInSwipeableView(self.cardStackView)
        
        self.cardStackView.nextView = self.nextViewForSwipeableView(self.cardStackView)
        self.cardStackView.previousView = self.previousViewForSwipeableView(self.cardStackView)
        
        self.cardStackView.didSwipe = self.swipeableViewCardWasSwiped(self.cardStackView)
        
        self.cardStackView.swiping = { (view: UIView, _, translation: CGPoint) in
            guard let cardView = view.subviews.first as? RestaurantCardView else { return }
            cardView.heartImageView.alpha = translation.x / 100
        }
        
        self.cardStackView.didCancel = { (view: UIView) in
            guard let cardView = view.subviews.first as? RestaurantCardView else { return }
            UIView.animateWithDuration(0.5, animations: {
                cardView.heartImageView.alpha = 0.0
            })
        }
        
        self.cardStackIndex = -1
        self.cardStackView.discardViews()
        self.cardStackView.loadViews()
    }
    
    func numberOfViewsInSwipeableView(swipeableView: ZLSwipeableView) -> UInt {
        return UInt(2)
    }
    
    func nextViewForSwipeableView(swipeableView: ZLSwipeableView)() -> UIView? {
        guard self.cardStackIndex + 1 < (self.dishes?.count ?? 0) else { return nil }
        let dish = self.dishes![self.cardStackIndex + 1]
        self.cardStackIndex += 1
        
        return self.cardForDish(dish, inSwipeableView: swipeableView)
    }
    
    func previousViewForSwipeableView(swipeableView: ZLSwipeableView)() -> UIView? {
        guard self.cardStackIndex - 1 >= 0 && self.dishes != nil else { return nil }
        let dish = self.dishes![self.cardStackIndex - 1]
        self.cardStackIndex -= 1
        
        return self.cardForDish(dish, inSwipeableView: swipeableView)
    }
    
    private func cardForDish(dish: Dish, inSwipeableView swipeableView: ZLSwipeableView) -> UIView? {
        let card = UIView(frame: swipeableView.bounds)
        let content = NSBundle.mainBundle().loadNibNamed("RestaurantCardView", owner: self, options: nil).first! as! RestaurantCardView
        
        card.backgroundColor = UIColor.clearColor()
        card.layer.shouldRasterize = true
        card.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        card.layer.shadowColor = UIColor.blackColor().CGColor
        card.layer.shadowOpacity = 0.07
        card.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        card.layer.shadowRadius = 15.0
        
        content.imageView.setImageWithURL(NSURL(string: dish.photo)!, placeholderImage: nil)
        
        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)
        
        let metrics = ["width": card.bounds.width, "height": card.bounds.height]
        let views = ["card": card, "content": content]
        ["H:|[content(width)]", "V:|[content(height)]"].forEach {
            card.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat($0,
                options: .AlignAllLeft,
                metrics: metrics,
                views: views))
        }
        
        return card
    }
}

extension RestaurantFeedViewController { // SwipeableView Delegate
    func swipeableViewCardWasSwiped(swipeableView: ZLSwipeableView)(view: UIView, inDirection direction: Direction, directionVector: CGVector) {
        let dish = self.dishes![self.swipedCardIndex]
        
        switch direction {
        case Direction.Right:
            dish.saveToShortList()
        case Direction.Left:
            dish.saveToDiscardList()
            
        default:
            break
        }
        
        self.swipedCardIndex += 1
        self.updateState()
    }
}

