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
    
    
    override func viewDidLoad() {
        if let myriadPro: UIFont = UIFont(name: "Myriad Pro", size: 20){
            let attrDict: [NSObject: AnyObject] = [NSFontAttributeName: myriadPro]
            self.navigationController?.navigationBar.titleTextAttributes = attrDict
        }
        
        webView.delegate = self
        self.webView.scrollView.scrollEnabled = false // Uncomment this to disable external scrolling of the UIWebView (i.e. only use this if Jonah can't make the website mobile-friendly)
        
        loadURL("https://script.google.com/macros/s/AKfycbxHk_GXziSAwSH6umVyz3LnnbgpkA9BnqvL2ILeFdhdUkLKobg/exec?splash=true")
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
    }

}