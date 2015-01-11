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
    @IBOutlet weak var disclaimer: UITextView!
    
    var data: NSDictionary?
    var edited: Bool = false
    
    override func viewDidLoad() {
        name.delegate = self
        
        // This convoluted mess adds a hyperlink to the design guide to make the description look nice
        let linkText: NSMutableAttributedString = NSMutableAttributedString(string: "All registered trademarks (unless otherwise stated) are those of Key Club International. The primary color (\"Key Club blue\") and font (\"Myriad Pro\") used for this application are recommended by Key Club International in their \"2014 Key Club Design Guide\" (available here).")
        linkText.addAttribute(NSLinkAttributeName, value: "http://keyclub.org/Libraries/design_elements/Fall_guide_2014.sflb.ashx", range: NSMakeRange(266, 4))
        disclaimer.attributedText = linkText
        disclaimer.font = UIFont(name: "Myriad Pro", size: 13)
        disclaimer.textColor = UIColor.lightGrayColor()
        
        if let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.Key-Club") {
            if let nameStr: String = defaults.valueForKey("name") as? String {
                not.hidden = false
                filledName.hidden = false
                name.hidden = true
                
                name.text = nil
                filledName.text = nameStr
            } else {
                not.hidden = true
                filledName.hidden = true
                name.hidden = false
                name.becomeFirstResponder()
            }
        }
        data = self.getData()
    }
    
    override func viewDidDisappear(animated: Bool) {
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
        if edited {
            if let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.Key-Club") {
                if let code: String = name.text {
                    if !code.isEmpty {
                        var nameStr: String = ""
                        if let codeDict: NSDictionary = data {
                            if let nameFromCode: String = codeDict.valueForKey(code.lowercaseString) as? String {
                                nameStr = nameFromCode
                            } else {
                                alert("Secret code not found", message: "Check that the code was entered properly.")
                            }
                        } else {
                            alert("Data pull failed", message: "Unable to pull sign in database; check your connection.")
                            data = self.getData()
                        }
                        
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
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        saveName()
        return true
    }
    
    @IBAction func changeName() {
        edited = true
        
        not.hidden = true
        filledName.hidden = true
        name.hidden = false
        
        name.becomeFirstResponder()
    }
    
    func getData() -> NSDictionary? {
        let data: NSData? = NSData(contentsOfURL: NSURL(string: "https://api.myjson.com/bins/307ej")!)
        if let req = data {
            var error: NSError?
            if let JSON: NSDictionary = NSJSONSerialization.JSONObjectWithData(req, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
                return JSON
            }
        }
        return nil
    }
    
    func alert(title: String, message: String) {
        if let gotModernAlert: AnyClass = NSClassFromString("UIAlertController") {
            let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let action: UIAlertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
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