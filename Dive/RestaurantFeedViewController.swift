//
//  RestaurantFeedViewController.swift
//  Dive
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
        case Ready
        case Empty
    }
    
    // MARK: Properties
    @IBOutlet var cardStackView: ZLSwipeableView!
    @IBOutlet var distanceSlider: UISlider!
    @IBOutlet var permissionsContainerView: UIView!
    @IBOutlet var emptyContainerView: UIView!
    
    private var cardStackIndex: Int = 0
    private var swipedCardIndex: Int = 0
    
    private var dishes: [Dish] = [] {
        didSet {
            self.updateState()
        }
    }
    
    private var state: State = .Unknown {
        didSet {
            guard self.state != oldValue else { return }
            
            self.cardStackView.hidden = [.Unknown, .Unauthorized].contains(self.state)
            self.permissionsContainerView.hidden = [.Unknown, .Ready, .Empty].contains(self.state)
            self.emptyContainerView.hidden = [.Unknown, .Unauthorized, .Ready].contains(self.state)
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.distanceSlider.setThumbImage(UIImage(named: "SliderThumb"),
            forState: .Normal)

        self.updateState()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Dish.all {
            self.dishes = $0
            self.reloadDataForSwipeableView(self.cardStackView)
        }
    }
    
    // MARK: Mutators
    func updateState() {
        print(swipedCardIndex, self.dishes.count)
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            self.state = .Unauthorized
        } else if self.swipedCardIndex == (self.dishes.count - 1) {
            self.state = .Empty
        } else {
            self.state = .Ready
        }
    }
}

extension RestaurantFeedViewController { // SwipeableView Data Source
    func reloadDataForSwipeableView(swipeableView: ZLSwipeableView) {
        self.cardStackView.numberOfActiveView = self.numberOfViewsInSwipeableView(self.cardStackView)
        
        self.cardStackView.nextView = self.nextViewForSwipeableView(self.cardStackView)
        self.cardStackView.previousView = self.previousViewForSwipeableView(self.cardStackView)
        
        self.cardStackView.didEnd = self.swipeableViewCardWasSwiped(self.cardStackView)
        self.cardStackView.loadViews()
    }
    
    func numberOfViewsInSwipeableView(swipeableView: ZLSwipeableView) -> UInt {
        return UInt(3)
    }
    
    func nextViewForSwipeableView(swipeableView: ZLSwipeableView)() -> UIView? {
        guard self.cardStackIndex + 1 < self.dishes.count else { return nil }
        let dish = self.dishes[self.cardStackIndex + 1]
        self.cardStackIndex += 1
        
        return self.cardForDish(dish, inSwipeableView: swipeableView)
    }
    
    func previousViewForSwipeableView(swipeableView: ZLSwipeableView)() -> UIView? {
        guard self.cardStackIndex - 1 >= 0 else { return nil }
        let dish = self.dishes[self.cardStackIndex - 1]
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
        content.label.text = dish.restaurant.name
        
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
    func swipeableViewCardWasSwiped(swipeableView: ZLSwipeableView)(view: UIView, atLocation: CGPoint) {
        self.swipedCardIndex += 1
        self.updateState()
    }
}

