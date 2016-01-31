//
//  RestaurantDishesPageViewController.swift
//  Forage
//
//  Created by PATRICK PERINI on 1/30/16.
//  Copyright © 2016 atomic. All rights reserved.
//

import UIKit

@IBDesignable
class RestaurantDishesPageViewController: UIPageViewController {
    // MARK: Properties
    @IBInspectable var pageControlHeight: CGFloat = 0.0
    
    private var transitioningPageIndex: Int = 0
    var currentPageIndex: Int = 0 {
        didSet {
            self.pageControl.currentPage = self.currentPageIndex
        }
    }
    
    var pageControl: UIPageControl!
    var dishes: [Dish] = [] {
        didSet {
            self.setViewControllers([self.pageViewController(self, viewControllerAtIndex: 0)],
                direction: .Forward,
                animated: false,
                completion: nil)
            
            self.pageControl.numberOfPages = self.dishes.count
            self.pageControl.currentPage = 0
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
                
        // Setup Page Control
        self.pageControl = UIPageControl()
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.pageControl)

        self.view.addConstraint(NSLayoutConstraint(item: self.pageControl,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: .Leading,
            multiplier: 1.0,
            constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.pageControl,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.pageControl,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: .Trailing,
            multiplier: 1.0,
            constant: 0.0))
        self.pageControl.addConstraint(NSLayoutConstraint(item: self.pageControl,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0,
            constant: self.pageControlHeight))
    }
}

extension RestaurantDishesPageViewController: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerAtIndex index: Int) -> UIViewController {
        let dish = self.dishes[index]
        
        let vc = UIViewController()
        let imageView = UIImageView()
        let container = vc.view
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(imageView)
        
        let metrics = ["width": container.bounds.width, "height": container.bounds.height]
        let views = ["container": container, "imageView": imageView]
        ["H:|[imageView(width)]", "V:|[imageView(height)]"].forEach {
            container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat($0,
                options: .AlignAllLeft,
                metrics: metrics,
                views: views))
        }
        
        imageView.backgroundColor = UIColor.blackColor()
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.setImageWithURL(NSURL(string: dish.photo)!, placeholderImage: nil)
        
        container.tag = index
        return vc
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let index = viewController.view.tag
        guard index - 1 >= 0 else { return nil }
        
        return self.pageViewController(self, viewControllerAtIndex: index - 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let index = viewController.view.tag
        guard index + 1 < self.dishes.count else { return nil }
        
        return self.pageViewController(self, viewControllerAtIndex: index + 1)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.dishes.count
    }
}

extension RestaurantDishesPageViewController: UIPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        self.transitioningPageIndex = pendingViewControllers.first!.view.tag
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.currentPageIndex = self.transitioningPageIndex
    }
}
