//
//  SettingsViewController.swift
//  Key Club
//
//  Created by Cameron Bernhardt on 12/2/14.
//  Copyright (c) 2014 Cameron Bernhardt. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var filledName: UILabel!
    @IBOutlet weak var not: UIButton!
    
    override func viewDidLoad() {
        name.delegate = self
        if let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.Key-Club") {
            if let nameStr: String = defaults.valueForKey("name") as? String {
                not.hidden = false
                filledName.hidden = false
                name.hidden = true
                
                name.text = nameStr
                filledName.text = nameStr
            } else {
                not.hidden = true
                filledName.hidden = true
                name.hidden = false
                name.becomeFirstResponder()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        saveName()
    }
    
    func textViewDidChange(textView: UITextView) {
        let fixedWidth: CGFloat = textView.frame.size.width
        let newSize: CGSize = textView.sizeThatFits(CGSizeMake(fixedWidth, CGFloat.max))
        var newFrame: CGRect = textView.frame
        newFrame.size = CGSizeMake(CGFloat(fmaxf(Float(newSize.width), Float(fixedWidth))), newSize.height)
        textView.frame = newFrame
    }
    
    
    func saveName() {
        if let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.Key-Club") {
            if let nameStr: String = name.text {
                // Check to make sure not empty and not nil
                let nameArr: [String] = nameStr.split(" ")
                var newStr = ""
                for i in nameArr {
                    newStr += i
                }
                
                if newStr != "" {
                    let encodedNameString = nameStr.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
                    
                    defaults.setObject(nameStr, forKey: "name")
                    defaults.setObject(encodedNameString, forKey: "encoded_name")
                    
                    not.hidden = false
                    filledName.hidden = false
                    name.hidden = true
                    
                    filledName.text = nameStr
                }
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        saveName()
        return true
    }
    
    @IBAction func changeName() {
        not.hidden = true
        filledName.hidden = true
        name.hidden = false
        
        name.becomeFirstResponder()
    }
}