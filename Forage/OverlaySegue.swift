//
//  OverlaySegue.swift
//  Forage
//
//  Created by PATRICK PERINI on 1/30/16.
//  Copyright © 2016 atomic. All rights reserved.
//

import UIKit

class OverlaySegue: UIStoryboardSegue {
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

class UnwindOverlaySegue: UIStoryboardSegue {
    override func perform() {
        let sourceView = self.sourceViewController.view.snapshotViewAfterScreenUpdates(false)
        self.sourceViewController.dismissViewControllerAnimated(false,
            completion: nil)
        
        UIApplication.sharedApplication().keyWindow?.addSubview(sourceView)
        UIView.animateWithDuration(0.10, animations: {
            sourceView.alpha = 0.0
        }, completion: { (_) in
            sourceView.removeFromSuperview()
        })
    }
}
