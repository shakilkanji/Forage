//
//  ShortListViewController.swift
//  Dive
//
//  Created by Shakil Kanji on 1/22/16.
//  Copyright © 2016 atomic. All rights reserved.
//

import UIKit
import CoreLocation

private let reuseIdentifier = "cell"
private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)

class ShortListViewController: UICollectionViewController, CLLocationManagerDelegate {
    
//    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        self.collectionView?.backgroundColor = UIColor.blueColor()
        
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestAlwaysAuthorization()
//        locationManager.startUpdatingLocation()
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ShortListCell
        
        cell.backgroundColor = UIColor.lightGrayColor()
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        cell.layer.cornerRadius = 5.0
        
        return cell
    }
}