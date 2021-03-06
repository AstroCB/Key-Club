//
//  WebViewController.swift
//  Key Club
//
//  Created by Cameron Bernhardt on 1/7/15.
//  Copyright (c) 2015 Cameron Bernhardt. All rights reserved.
//

import Foundation
import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        if let myriadPro: UIFont = UIFont(name: "Myriad Pro", size: 20){
            let attrDict: [NSObject: AnyObject] = [NSFontAttributeName: myriadPro]
            self.navigationController?.navigationBar.titleTextAttributes = attrDict
        }
        self.webView.delegate = self
        
        // Disable bouncing to appear semi-native
        self.webView.scrollView.bounces = false
        self.webView.scrollView.indicatorStyle = .White
        self.webView.scrollView.showsHorizontalScrollIndicator = false
        
        self.loadURL("https://dl.dropboxusercontent.com/u/24397004/Permanent%20To%20Share/tweet.html")
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
    
    @IBAction func reloadCurrent() {
        self.webView.reload()
    }
    
    @IBAction func goBack() {
        self.webView.goBack()
    }
    
    @IBAction func goForward() {
        self.webView.goForward()
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if !self.webView.canGoBack {
            self.backButton.enabled = false
        } else {
            self.backButton.enabled = true
        }
        
        if !self.webView.canGoForward {
            self.forwardButton.enabled = false
        } else {
            self.forwardButton.enabled = true
        }
    }
    
}