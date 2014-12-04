//
//  TabViewController.swift
//  Key Club
//
//  Created by Cameron Bernhardt on 12/3/14.
//  Copyright (c) 2014 Cameron Bernhardt. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    override func viewDidLoad() {
        if let controllers: [AnyObject] = self.viewControllers {
            if let view: SignupViewController = controllers[1] as? SignupViewController {
                let button: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "sendSignup")
                
                self.navigationItem.rightBarButtonItem = button
            }
        }
    }
    
    internal func sendSignup() {
        let detailView: DetailViewController = (self.viewControllers as [UIViewController])[0] as DetailViewController
        let signView: SignupViewController = (self.viewControllers as [UIViewController])[1] as SignupViewController
        
        if let act: UIActivityIndicatorView = signView.activity {
            act.startAnimating()
        } else {
            detailView.activity.startAnimating()
        }
        if let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.Key-Club"){
            if let signer: String = defaults.valueForKey("encoded_name") as? String {
                if let url: NSURL = NSURL(string: "https://script.google.com/macros/s/AKfycbxHk_GXziSAwSH6umVyz3LnnbgpkA9BnqvL2ILeFdhdUkLKobg/exec?post=true&eventRow=\(detailView.key)&person=\(signer)") {
                    let session = NSURLSession.sharedSession()
                    let dataTask = session.dataTaskWithURL(url, completionHandler: {(data: NSData!, response:NSURLResponse!,
                        error: NSError!) -> Void in
                        dispatch_async(dispatch_get_main_queue(), {
                            signView.popView()
                            
                            if let act: UIActivityIndicatorView = signView.activity {
                                act.stopAnimating()
                            } else {
                                detailView.activity.stopAnimating();
                            }
                            
                            self.alert(detailView.curEvent.valueForKey("pretty_name") as String)
                        })
                        // TODO: Check to see if they've already signed up
                    })
                    
                    dataTask.resume()
                }
            }
        }
    }
    
    func alert(event: String) {
        let myAlert: UIAlertController = UIAlertController(title: "Signed up!", message: "You've successfully signed up for \(event).", preferredStyle: .Alert)
        myAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
}