//
//  MAActivityIndicatorView.swift
//  Yelpify
//
//  Created by Mark Anderson on 2/21/16.
//  Copyright © 2016 markmakingmusic. All rights reserved.
//

import UIKit

class MAActivityIndicatorView: UIView {
    let actiview = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    weak var currentTopViewController: UIViewController?

    static let sharedInstance: MAActivityIndicatorView = {
        let singleton = MAActivityIndicatorView()
        if let topViewController = MAActivityIndicatorView.getTopViewController() {
            singleton.frame = topViewController.view.bounds
            singleton.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
            singleton.actiview.frame = singleton.frame
            singleton.actiview.stopAnimating()
            singleton.addSubview(singleton.actiview)
        }
        return singleton
    }()

    class func getTopViewController() -> UIViewController? {
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            return delegate.window?.rootViewController
        }
        return nil
    }

    func stashTopViewController() {
        currentTopViewController = MAActivityIndicatorView.getTopViewController()
    }

    class func show() {
        let sharedInstance = MAActivityIndicatorView.sharedInstance
        sharedInstance.stashTopViewController()
        if sharedInstance.superview == nil {
            sharedInstance.currentTopViewController?.view.addSubview(sharedInstance)
            sharedInstance.currentTopViewController?.navigationController?.view.userInteractionEnabled = false
            sharedInstance.actiview.startAnimating()
        }
    }

    class func hide() {
        let sharedInstance = MAActivityIndicatorView.sharedInstance
        if sharedInstance.superview != nil {
            sharedInstance.actiview.stopAnimating()
            sharedInstance.currentTopViewController?.navigationController?.view.userInteractionEnabled = true
            sharedInstance.currentTopViewController = nil
            sharedInstance.removeFromSuperview()
        }
    }
}
