//
//  SettingsViewController.swift
//  Key Club
//
//  Created by Cameron Bernhardt on 12/2/14.
//  Copyright (c) 2014 Cameron Bernhardt. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var name: UITextField!
    
    override func viewDidLoad() {
        if let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.Key-Club") {
            if let nameStr: String = defaults.valueForKey("name") as? String {
                name.text = nameStr
            } else {
                name.becomeFirstResponder()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        saveName()
    }
    
    func saveName() {
        if let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.Key-Club") {
            if let nameStr: String = name.text {
                let encodedNameString = nameStr.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
                
                defaults.setObject(nameStr, forKey: "name")
                defaults.setObject(encodedNameString, forKey: "encoded_name")
            }
        }
    }
}