//
//  ProfileViewController.swift
//  Key Club
//
//  Created by Cameron Bernhardt on 1/25/15.
//  Copyright (c) 2015 Cameron Bernhardt. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    
    
    override func viewDidLoad() {
        if let myriadPro: UIFont = UIFont(name: "Myriad Pro", size: 20){
            let attrDict: [NSObject: AnyObject] = [NSFontAttributeName: myriadPro]
            self.navigationController?.navigationBar.titleTextAttributes = attrDict
        }
        
        webView.delegate = self
        
        // Disable bouncing to appear semi-native
        webView.scrollView.bounces = false
        if let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.Key-Club"){
            if let user: String = defaults.valueForKey("encoded_name") as? String {
                loadURL("https://script.google.com/macros/s/AKfycbxHk_GXziSAwSH6umVyz3LnnbgpkA9BnqvL2ILeFdhdUkLKobg/exec?leadWeb=true&person=\(user)")
            } else {
                self.performSegueWithIdentifier("logInFromProfile", sender: self)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadURL(url: String) {
        if let urlToLoad: NSURL = NSURL(string: url) {
            self.webView.loadRequest(NSURLRequest(URL: urlToLoad))
        }
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}