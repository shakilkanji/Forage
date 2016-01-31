//
//  OverlaySegue.swift
//  Forage
//
//  Created by PATRICK PERINI on 1/30/16.
//  Copyright © 2016 atomic. All rights reserved.
//

import UIKit

class OverlaySegue: UIStoryboardSegue {
    class Unwind: UIStoryboardSegue {
        override func perform() {
            let destinationView = self.destinationViewController.view.snapshotViewAfterScreenUpdates(false)
            self.destinationViewController.dismissViewControllerAnimated(false,
                completion: nil)
            
            UIApplication.sharedApplication().keyWindow?.addSubview(destinationView)
            UIView.animateWithDuration(0.10, animations: {
                destinationView.alpha = 0.0
            }, completion: { (_) in
                destinationView.removeFromSuperview()
            })
        }
    }
    
    override func perform() {
        let sourceView = UIApplication.sharedApplication().keyWindow!.snapshotViewAfterScreenUpdates(false)
        self.destinationViewController.view.insertSubview(sourceView, atIndex: 0)
        
        self.destinationViewController.view.alpha = 0.0
        UIApplication.sharedApplication().keyWindow?.addSubview(self.destinationViewController.view)
        
        UIView.animateWithDuration(0.10, animations: {
            self.destinationViewController.view.alpha = 1.0
        }, completion: { (_) in
            self.sourceViewController.presentViewController(self.destinationViewController,
                animated: false,
                completion: nil)
        })
    }
}
