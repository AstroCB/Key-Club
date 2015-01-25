//
//  OfficerViewController.swift
//  Key Club
//
//  Created by Cameron Bernhardt on 1/17/15.
//  Copyright (c) 2015 Cameron Bernhardt. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class OfficerViewController: UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    let officers: [String: [String: String]] = ["Michelle Ko - President": ["Email": "ko.michelle@live.com", "Phone": "323-370-5141"], "Yusuf Mahmood - Vice President": ["Email": "ymahmood.work@gmail.com", "Phone": "443-632-8343"], "Angela Zhang - Membership Secretary": ["Email": "angelazhang117@gmail.com", "Phone": "443-418-8273"], "Ben Lee - Treasurer": ["Email": "benlee59@gmail.com", "Phone": "410-214-7780"], "Ni Tial - Recording Secretary": ["Email": "cydindin@gmail.com", "Phone": "443-621-3285"], "Lyra Morina - Historian": ["Email": "lyraamor@yahoo.com", "Phone": "443-717-0520"], "Sahana Raju - Historian": ["Email": "sahana_rj@yahoo.com", "Phone": "443-418-9842"], "Sumin Woo - Editor": ["Email": "suminwoo98@gmail.com", "Phone": "410-916-9029"]]
    
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        // Required class method
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        // Required class method
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func contactOfficer(sender: AnyObject) {
        if let mySender: UILongPressGestureRecognizer = sender as? UILongPressGestureRecognizer {
            if mySender.state == .Began {
                if let myView: UILabel = mySender.view as? UILabel {
                    let name: String = myView.text!
                    if let officerInfo: [String: String] = officers[name] {
                        let firstName: String = name.split(" ")[0]
                        var position: String = ""
                        
                        for var i = 0; i < name.split(" ").count; i++ {
                            if i > 2 {
                                position += name.split(" ")[i] + " "
                            }
                        }
                        
                        if let gotModernAlert: AnyClass = NSClassFromString("UIAlertController") {
                            let dialog: UIAlertController = UIAlertController(title: "Contact \(firstName)", message: "Contact the Key Club \(position)", preferredStyle: .ActionSheet)
                            
                            if MFMailComposeViewController.canSendMail() {
                                let mail: UIAlertAction = UIAlertAction(title: "Mail", style: .Default, handler: { UIAlertAction -> Void in
                                    
                                    let mailController: MFMailComposeViewController = MFMailComposeViewController()
                                    mailController.mailComposeDelegate = self
                                    
                                    let email: String = officerInfo["Email"]!
                                    mailController.setToRecipients([email])
                                    
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.presentViewController(mailController, animated: true, completion: nil)
                                    })
                                })
                                dialog.addAction(mail)
                            }
                            
                            
                            if MFMessageComposeViewController.canSendText() {
                                let message: UIAlertAction = UIAlertAction(title: "Message", style: .Default, handler: { UIAlertAction -> Void in
                                    
                                    let messageController: MFMessageComposeViewController = MFMessageComposeViewController()
                                    messageController.messageComposeDelegate = self
                                    
                                    let phoneNumber: String = officerInfo["Phone"]!
                                    messageController.recipients = [phoneNumber]
                                    
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.presentViewController(messageController, animated: true, completion: nil)
                                    })
                                })
                                dialog.addAction(message)
                            }
                            
                            dialog.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                self.presentViewController(dialog, animated: true, completion: nil)
                            })
                        } else {
                            let alertView: UIAlertView = UIAlertView(title: "Contact \(firstName)", message: "Contact the Key Club \(position)", delegate: nil, cancelButtonTitle: "Cancel")
                            
                            alertView.alertViewStyle = .PlainTextInput
                            
                            if let email: String = officerInfo["Email"] {
                                alertView.textFieldAtIndex(0)?.text = "Mail: \(email)"
                            }
                            if let phone: String = officerInfo["Phone"] {
                                alertView.textFieldAtIndex(0)?.text = "\(alertView.textFieldAtIndex(0)!.text)\nPhone: \(phone)"
                            }
                            
                            alertView.show()
                        }
                    }
                }
            }
        }
    }
}