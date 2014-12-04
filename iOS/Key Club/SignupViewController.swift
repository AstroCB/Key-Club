//
//  SignupViewController.swift
//  Key Club
//
//  Created by Cameron Bernhardt on 11/28/14.
//  Copyright (c) 2014 Cameron Bernhardt. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activity.hidesWhenStopped = true
        self.popView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Allows pressing return to dismiss keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func popView() {
        let myKey: String = (self.tabBarController?.viewControllers as [DetailViewController])[0].key
        if let event: NSDictionary = self.getData()?.valueForKey(myKey) as? NSDictionary {
            if let signers: String = event.valueForKey("signups") as? String {
                let signArr: [String] = signers.split(",")
                var signStr = ""
                for i in signArr {
                    signStr += "\(i)\n\n"
                }
                if let text: UITextView = textView {
                    textView.text = signStr
                }
            }
        }
    }

    func getData() -> NSDictionary? {
        let data: NSData? = NSData(contentsOfURL: NSURL(string: "https://api.myjson.com/bins/tdd3")!)
        if let req = data {
            var error: NSError?
            if let JSON: NSDictionary = NSJSONSerialization.JSONObjectWithData(req, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
                return JSON
            }
        }
        return nil
    }
}
