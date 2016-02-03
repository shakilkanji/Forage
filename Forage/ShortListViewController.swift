//
//  ShortListViewController.swift
//  Forage
//
//  Created by Shakil Kanji on 1/22/16.
//  Copyright © 2016 atomic. All rights reserved.
//

import UIKit
import CoreLocation
import DZNEmptyDataSet

class ShortListViewController: UICollectionViewController {
    // MARK: Constants
    private static let reuseIdentifier = "ShortListCell"
    
    // MARK: Properties
    var dishes: [Dish] = []
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Dish.shortList { (dishes: [Dish]) in
            self.dishes = dishes
            self.collectionView?.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier ?? "" {
        case "ShowRestaurant":
            let destinationVC = segue.destinationViewController as! RestaurantViewController
            let dish = sender as! Dish
            destinationVC.restaurant = dish.restaurant
            destinationVC.initialDish = dish
        
        default:
            break
        }
    }
    
    // MARK: Responders
    @IBAction func backButtonWasPressed(sender: UIButton?) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func prepareForUnwind(sender: UIStoryboardSegue?) {
    }
}

extension ShortListViewController { // Collection View Data Source
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dishes.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ShortListViewController.reuseIdentifier, forIndexPath: indexPath) as! ShortListCell
        let dish = self.dishes[indexPath.item]
        
        cell.imageView.setImageWithURL(NSURL(string: dish.photo)!, placeholderImage: nil)
        
        return cell
    }
}

extension ShortListViewController { // Collection View Delegation
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let dish = self.dishes[indexPath.item]
        self.performSegueWithIdentifier("ShowRestaurant",
            sender: dish)
    }
}

extension ShortListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = (collectionView.bounds.width / 2.0) -
            ((collectionView.contentInset.left + collectionView.contentInset.right) +
            ((collectionView.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing * 2.0))
        
        return CGSizeMake(size, size)
    }
}

extension ShortListViewController: DZNEmptyDataSetSource {
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "ShortListEmpty")
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No saved photos"
        let attributes: NSDictionary = [NSFontAttributeName: UIFont.systemFontOfSize(20.0), NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attributes as? [String : AnyObject])
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Swipe right on some food pics to add them to your short list."
        let attributes: NSDictionary = [NSFontAttributeName: UIFont.systemFontOfSize(16.0), NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attributes as? [String : AnyObject])
    }
}