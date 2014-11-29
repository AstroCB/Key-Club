//
//  SignupViewController.swift
//  Key Club
//
//  Created by Cameron Bernhardt on 11/28/14.
//  Copyright (c) 2014 Cameron Bernhardt. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var person: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func sendSignup() {
        let myKey: String = (self.tabBarController?.viewControllers as [DetailViewController])[0].key
        if let url: NSURL = NSURL(string: "https://script.google.com/macros/s/AKfycbxHk_GXziSAwSH6umVyz3LnnbgpkA9BnqvL2ILeFdhdUkLKobg/exec?post=true&eventRow=\(myKey)&person=\(self.person.text)") {
            
            let session = NSURLSession.sharedSession()
            let dataTask = session.dataTaskWithURL(url, completionHandler: {(data: NSData!, response:NSURLResponse!,
                error: NSError!) -> Void in
                println("\(self.person.text) added")
                // Disable button later and provide confirmation
            })
            
            dataTask.resume()
        }
        
        
    }
}