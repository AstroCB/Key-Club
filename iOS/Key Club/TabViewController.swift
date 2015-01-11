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
        
        if let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.Key-Club"){
            if let signer: String = defaults.valueForKey("encoded_name") as? String {
                
                if let url: NSURL = NSURL(string: "https://script.google.com/macros/s/AKfycbxHk_GXziSAwSH6umVyz3LnnbgpkA9BnqvL2ILeFdhdUkLKobg/exec?post=true&eventRow=\(detailView.key)&person=\(signer)") {
                    let session: NSURLSession = NSURLSession.sharedSession()
                    
                    // Set max signups
                    
                    // Still room
                    if let detail: UIActivityIndicatorView = detailView.activity {
                        detail.startAnimating()
                    }
                    
                    if let sign: UIActivityIndicatorView = signView.activity {
                        sign.startAnimating()
                    }
                    
                    let dataTask: NSURLSessionDataTask = session.dataTaskWithURL(url, completionHandler: {(data: NSData!, response: NSURLResponse!,
                        error: NSError!) -> Void in
                        dispatch_async(dispatch_get_main_queue(), {
                            signView.numSignedUp = 0
                            signView.popView()
                            
                            if let nextDetail: UIActivityIndicatorView = detailView.activity {
                                nextDetail.stopAnimating()
                            }
                            
                            if let nextSign: UIActivityIndicatorView = signView.activity {
                                nextSign.stopAnimating()
                            }
                            if signView.numSignedUp < detailView.maxNum {
                                let event: String = detailView.curEvent.valueForKey("pretty_name") as String
                                self.alert("Signed up!", message:"You've successfully signed up for \(event).")
                            } else {
                                // Too many people signed up
                                self.alert("Too many signups", message: "You've been placed in a waiting queue.")
                            }
                        })
                    })
                    
                    dataTask.resume()
                    
                }
            } else {
                self.performSegueWithIdentifier("signIn", sender: self)
            }
        }
    }
    
    func alert(title: String, message: String) {
        if let getModernAlert: AnyClass = NSClassFromString("UIAlertController") {
            let myAlert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            myAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(myAlert, animated: true, completion: nil)
        } else {
            let alert: UIAlertView = UIAlertView()
            alert.delegate = self
            
            alert.title = title
            alert.message = message
            alert.addButtonWithTitle("OK")
            
            alert.show()
        }
    }
}