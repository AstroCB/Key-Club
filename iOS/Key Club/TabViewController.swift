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
                let signUpButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "sendSignup")
                let shareButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share")
                
                self.navigationItem.rightBarButtonItems = [signUpButton, shareButton]
            }
        }
    }
    
    internal func sendSignup() {
        let detailView: DetailViewController = (self.viewControllers as [UIViewController])[0] as DetailViewController
        let signView: SignupViewController = (self.viewControllers as [UIViewController])[1] as SignupViewController
        
        if let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.Key-Club") {
            if let signer: String = defaults.valueForKey("encoded_name") as? String {
                
                if let url: NSURL = NSURL(string: "https://script.google.com/macros/s/AKfycbxHk_GXziSAwSH6umVyz3LnnbgpkA9BnqvL2ILeFdhdUkLKobg/exec?post=true&eventRow=\(detailView.key)&person=\(signer)") {
                    let session: NSURLSession = NSURLSession.sharedSession()
                    
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
                                alert("Signed up!", withMessage:"You've successfully signed up for \(event).", toView: self)
                            } else {
                                // Too many people signed up
                                alert("Too many signups", withMessage: "You've been placed in a waiting queue.", toView: self)
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
    
    internal func share() {
        let detailView: DetailViewController = (self.viewControllers as [UIViewController])[0] as DetailViewController // Need this VC for details
        
        // Grab all of the event details
        let name: String? = detailView.curEvent.valueForKey("pretty_name") as? String
        let description: String = detailView.details.text
        let date: String? = detailView.eventDescription.text
        var limit: String? = detailView.limit.text
        
        var objectsToShare: [AnyObject] = []
        
        // Fancy formatting and checking to get a contextualized string to share
        var shareString: String = ""
        
        if let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.Key-Club") {
            if let sharer: String = defaults.valueForKey("name") as? String {
                if let validName: String = name {
                    shareString += "\(sharer) has invited you to attend \(validName)."
                }
            }
        }
        
        if let validDate: String = date {
            if validDate != "Date" {
                let day: String = validDate.split("\n")[0]
                shareString += " The event takes place on \(day)"
                
                var time: String = validDate.split("\n")[1]
                if !time.isEmpty && time != "TBD" {
                    // Strip parentheses
                    time = dropFirst(time)
                    time = dropLast(time)
                    
                    // Check if a start and end time are provided, or just a start time
                    if time.rangeOfString("-") != nil {
                        shareString += " from \(time)."
                    } else {
                        shareString += " at \(time)."
                    }
                } else {
                    shareString += "."
                }
            }
        }
        
        if !description.isEmpty {
            if description != "Details" {
                shareString += " Here's what you'll be doing:\n\n\(description)\n\n"
            }
        }
        
        if let validLimit: String = limit {
            if validLimit != "Limit" {
                shareString += "You'd better hurry! There's a limit of \(validLimit) people."
            }
        }
        
        objectsToShare.append(shareString)
        
        if let URLToStore: NSURL = NSURL(string: "http://appstore.com/keyclub") { // Download link            objectsToShare.append(URLToStore)
        }
        
        let shareSheet: UIActivityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.presentViewController(shareSheet, animated: true, completion: nil)
    }
}