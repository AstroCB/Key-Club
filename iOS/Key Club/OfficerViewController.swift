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
import AddressBook
import AddressBookUI

class OfficerViewController: UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    let officers: [String: [String: String]] = ["Michelle Ko": ["Position": "President", "Email": "ko.michelle@live.com", "Phone": "323-370-5141"], "Yusuf Mahmood": ["Position": "Vice President", "Email": "ymahmood.work@gmail.com", "Phone": "443-632-8343"], "Angela Zhang": ["Position": "Membership Secretary", "Email": "angelazhang117@gmail.com", "Phone": "443-418-8273"], "Ben Lee": ["Position": "Treasurer", "Email": "benlee59@gmail.com", "Phone": "410-214-7780"], "Ni Tial": ["Position": "Recording Secretary", "Email": "cydindin@gmail.com", "Phone": "443-621-3285"], "Lyra Morina": ["Position": "Historian", "Email": "lyraamor@yahoo.com", "Phone": "443-717-0520"], "Sahana Raju": ["Position": "Historian", "Email": "sahana_rj@yahoo.com", "Phone": "443-418-9842"], "Sumin Woo": ["Position": "Editor", "Email": "suminwoo98@gmail.com", "Phone": "410-916-9029"]]
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        // Required class method
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        // Required class method
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func contactOfficer(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            if let myView: UILabel = sender.view as? UILabel {
                let name: String = myView.text!.split(" - ")[0] // Take the "name" part of the label (as opposed to the "position" part)
                let position: String = myView.text!.split(" - ")[1] // Grab position
                
                if let officerInfo: [String: String] = officers[name] {
                    let namePieces: [String] = name.split(" ")
                    
                    let firstName: String = namePieces[0]
                    let lastName: String = namePieces[1]
                    
                    if let gotModernAlert: AnyClass = NSClassFromString("UIAlertController") {
                        let dialog: UIAlertController = UIAlertController(title: "Contact \(firstName)", message: "Contact the Key Club \(position)", preferredStyle: .ActionSheet)
                        
                        // Contact via Email
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
                        
                        // Contact via Messages
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
                        
                        // Add to Contacts
                        switch ABAddressBookGetAuthorizationStatus(){ // Check Address Book permissions
                        case .Authorized:
                            if let addressBook: ABAddressBook = self.createAddressBook() {
                                dialog.addAction(UIAlertAction(title: "Add to Contacts", style: .Default, handler: { (UIAlertAction) -> Void in
                                    self.addToContacts(firstName, lastName: lastName, email: officerInfo["Email"], phone: officerInfo["Phone"], addressBook: addressBook)
                                }))
                            }
                        case .Denied:
                            println("Address Book access is denied")
                            
                        case .NotDetermined:
                            if let addressBook: ABAddressBookRef = createAddressBook() {
                                dialog.addAction(UIAlertAction(title: "Add to Contacts", style: .Default, handler: { (UIAlertAction) -> Void in
                                    ABAddressBookRequestAccessWithCompletion(addressBook,
                                        {(granted: Bool, error: CFError!) in
                                            if granted {
                                                self.addToContacts(firstName, lastName: lastName, email: officerInfo["Email"], phone: officerInfo["Phone"], addressBook: addressBook)
                                            } else {
                                                println("Access is not granted")
                                            }
                                    })
                                }))
                            }
                            
                        case .Restricted:
                            println("Address Book access is restricted")
                            
                        default:
                            println("Unhandled")
                        }
                        
                        dialog.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            // iPad support
                            if let popoverController = dialog.popoverPresentationController {
                                popoverController.sourceView = sender.view!
                                popoverController.sourceRect = sender.view!.bounds
                            }
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
    
    func createAddressBook() -> ABAddressBook? {
        var error: Unmanaged<CFError>?
        
        let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil,
            &error).takeRetainedValue()
        if error != nil {
            return nil
        } else {
            return addressBook
        }
    }
    
    
    func addToContacts(firstName: String, lastName: String, email: String?, phone: String?, addressBook: ABAddressBook) {
        let person: ABRecordRef = ABPersonCreate().takeRetainedValue()
        
        let couldSetFirstName: Bool = ABRecordSetValue(person, kABPersonFirstNameProperty, firstName as AnyObject, nil)
        let couldSetLastName: Bool = ABRecordSetValue(person, kABPersonLastNameProperty, lastName as AnyObject, nil)
        if let validEmail = email {
            let multiEmail: ABMutableMultiValue = ABMultiValueCreateMutable(ABPropertyType(kABMultiStringPropertyType)).takeRetainedValue()
            let didAddEmail: Bool = ABMultiValueAddValueAndLabel(multiEmail, email, kABHomeLabel, nil)
            
            if didAddEmail {
                ABRecordSetValue(person, kABPersonEmailProperty, multiEmail as AnyObject, nil)
            }
        }
        if let validPhone = phone {
            let multiPhone: ABMutableMultiValue = ABMultiValueCreateMutable(ABPropertyType(kABMultiStringPropertyType)).takeRetainedValue()
            let didAddPhone: Bool = ABMultiValueAddValueAndLabel(multiPhone, phone, kABPersonPhoneMobileLabel, nil)
            
            if didAddPhone {
                ABRecordSetValue(person, kABPersonPhoneProperty, multiPhone as AnyObject, nil)
            }
        }
        
        var error: Unmanaged<CFErrorRef>? = nil
        
        let couldAddPerson: Bool = ABAddressBookAddRecord(addressBook, person, &error)
        
        if couldAddPerson {
            println("Successfully added the person.")
        } else {
            println("Failed to add the person.")
        }
        
        if ABAddressBookHasUnsavedChanges(addressBook){
            var error: Unmanaged<CFErrorRef>? = nil
            let couldSaveAddressBook: Bool = ABAddressBookSave(addressBook, &error)
            
            if couldSaveAddressBook{
                println("Successfully saved the address book.")
                alert("Success", withMessage: "Successfully added \(firstName) \(lastName) to Contacts.", toView: self)
            } else {
                println("Failed to save the address book.")
                alert("Save failed", withMessage: "Unable to save contact", toView: self)
            }
        }
    }
    
    @IBAction func support() {
        if MFMailComposeViewController.canSendMail() {
            let mailController: MFMailComposeViewController = MFMailComposeViewController()
            mailController.mailComposeDelegate = self
            
            mailController.setToRecipients(["astroissues@icloud.com"])
            mailController.setSubject("Key Club Support Request")
            
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(mailController, animated: true, completion: nil)
            })
        }
    }
}