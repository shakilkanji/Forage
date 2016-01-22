//
//  RestaurantFeedViewController.swift
//  Dive
//
//  Created by PATRICK PERINI on 1/21/16.
//  Copyright © 2016 atomic. All rights reserved.
//

import UIKit
import ZLSwipeableViewSwift

@IBDesignable
class RestaurantFeedViewController: UIViewController {
    // MARK: Properties
    @IBOutlet var cardStackView: ZLSwipeableView!
    @IBInspectable var cardViewControllerIdentifier: String?
    
    private var cardStackIndex: Int = 0
    
    // MARK: Lifecycle
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadDataForSwipeableView(self.cardStackView)
    }
}

extension RestaurantFeedViewController { // SwipeableView Data Source
    func reloadDataForSwipeableView(swipeableView: ZLSwipeableView) {
        self.cardStackView.numberOfActiveView = self.numberOfViewsInSwipeableView(self.cardStackView)
        
        self.cardStackView.nextView = self.nextViewForSwipeableView(self.cardStackView)
        self.cardStackView.previousView = self.previousViewForSwipeableView(self.cardStackView)
        
        self.cardStackView.loadViews()
    }
    
    func numberOfViewsInSwipeableView(swipeableView: ZLSwipeableView) -> UInt {
        return UInt(10)
    }
    
    func nextViewForSwipeableView(swipeableView: ZLSwipeableView)() -> UIView? {
        guard let cardViewControllerIdentifier = self.cardViewControllerIdentifier else { return nil }
        guard let cardViewController = self.storyboard?.instantiateViewControllerWithIdentifier(cardViewControllerIdentifier) else { return nil }
        
        cardViewController.view.frame = self.cardStackView.bounds        
        return cardViewController.view
    }
    
    func previousViewForSwipeableView(swipeableView: ZLSwipeableView)() -> UIView? {
        return nil
    }
}

