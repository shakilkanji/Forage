//
//  ShortListViewController.swift
//  Dive
//
//  Created by Shakil Kanji on 1/22/16.
//  Copyright © 2016 atomic. All rights reserved.
//

import UIKit
import CoreLocation
import DZNEmptyDataSet

class ShortListViewController: UICollectionViewController, CLLocationManagerDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    private static let reuseIdentifier = "ShortListCell"
    
//    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        let backgroundColor = UIColor(red: 248, green: 248, blue: 248, alpha: 100)
        self.collectionView?.backgroundColor = backgroundColor
        
        self.collectionView?.emptyDataSetDelegate = self
        self.collectionView?.emptyDataSetSource = self
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestAlwaysAuthorization()
//        locationManager.startUpdatingLocation()
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ShortListViewController.reuseIdentifier, forIndexPath: indexPath) as! ShortListCell
        
        cell.backgroundColor = UIColor.lightGrayColor()
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        cell.layer.cornerRadius = 5.0
        
        return cell
    }
}

extension ShortListViewController { // DZNEmptyDataSetSource
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "Short List Empty Image")
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No saved photos"
        let attributes:NSDictionary = [NSFontAttributeName: UIFont.systemFontOfSize(20.0), NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attributes as? [String : AnyObject])
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Swipe right on some food pics to add them to your short list."
        let attributes:NSDictionary = [NSFontAttributeName: UIFont.systemFontOfSize(16.0), NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attributes as? [String : AnyObject])
    }
}