//
//  MasterViewController.swift
//  Key Club
//
//  Created by Cameron Bernhardt on 11/20/14.
//  Copyright (c) 2014 Cameron Bernhardt. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    /// Array of things to go in the table view.
    var objects: NSMutableArray = NSMutableArray()
    /// Data to be pulled from https://api.myjson.com/bins/tdd3
    var pulledData: NSDictionary = NSDictionary()
    /// This keeps track of which event goes to which cell so that the right data is used on segue.
    var tags: [String: String] = [String: String]()
    /// See if it's an initial load or a reload.
    var reload: Bool = false
    /// Keep this in the global scope to add it when not signed in.
    var settingsButton: UIBarButtonItem = UIBarButtonItem()
    /// Only show sign in warning after leaving settings.
    var firstTime: Bool = true
    /// Check to see if the buttons have been added (for login security).
    var noButtons: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Design fixes
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.clearsSelectionOnViewWillAppear = false
        
        var sizeOfTitle: CGFloat = 20
        
        if UIScreen.mainScreen().bounds.height <= 568.0 { // Shrink the title to fit the icons on 4s
            sizeOfTitle = 15
        }
        
        if let myriadPro: UIFont = UIFont(name: "Myriad Pro", size: sizeOfTitle) {
            let attrDict: [NSObject: AnyObject] = [NSFontAttributeName: myriadPro]
            self.navigationController?.navigationBar.titleTextAttributes = attrDict
        }
        
        // For whatever reason, iOS 7 doesn't invoke viewDidAppear when performing a segue on load, so setting self.firstTime here is necessary, but it leads to extraneous alerts if it's set here on iOS 8+; also, to prevent table view reload messes, reload has to be set to true since loadTable() isn't called even though the view loads (neither issue causes any problem in iOS 8+)
        if (UIDevice.currentDevice().systemVersion as NSString).doubleValue < 8.0 {
            self.firstTime = false
            self.reload = true
        }
        
        
        // Don't show events if not logged in to deter stalkers (?)
        self.settingsButton = UIBarButtonItem(image: UIImage(named: "Gear_Large"), landscapeImagePhone: UIImage(named: "Gear_Small"), style: UIBarButtonItemStyle.Plain, target: self, action: "goToSettings")
        self.settingsButton.tintColor = UIColor.grayColor()
        self.settingsButton.width = -1.0 // Remove auto-sizing
        self.navigationItem.leftBarButtonItem = self.settingsButton
        
        if isLoggedIn() {
            self.loadTable()
            self.loadIcons()
            
            dispatch_async(dispatch_get_main_queue(), { // Load up announcements first, as per Vincent's request
                self.performSegueWithIdentifier("loadInfo", sender: self)
            })
        } else {
            // If not logged in, go to Settings and remove reload button
            self.performSegueWithIdentifier("goToSettings", sender: self)
            self.navigationItem.rightBarButtonItems = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This fixes the odd issue where cells remain selected after using the left-to-right swipe gesture to return to the parent view controller
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let path: NSIndexPath = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(path, animated: animated)
        }
        
        if !self.firstTime {
            if isLoggedIn() {
                if self.noButtons {
                    loadTable()
                    loadIcons()
                    self.noButtons = false
                }
            } else {
                alert("Sign in required", withMessage: "Hey! For security purposes, you have to log in to see and sign up for events. If you need a code, see a Key Club officer.", toView: self)
            }
        } else {
            self.firstTime = false
        }
    }
    
    
    func insertNewObject(obj: AnyObject, date: String) {
        var dict: NSMutableDictionary = NSMutableDictionary()
        dict.setValue(obj, forKey: "name")
        dict.setValue(date, forKey: "date")
        
        self.objects.insertObject(dict, atIndex: 0)
        let indexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            let dict: NSDictionary = objects[indexPath.row] as! NSDictionary
            let object: String = dict.valueForKey("name") as! String
            if let realIndex: String = tags[object] {
                let val: NSDictionary = pulledData.valueForKey(realIndex) as! NSDictionary
                if let view: UITabBarController = segue.destinationViewController as? UITabBarController {
                    let views: [UIViewController] = (view.viewControllers as! [UIViewController])
                    if let nextView: DetailViewController = views[0] as? DetailViewController {
                        // Send values to next view to avoid another network call
                        nextView.curEvent = val
                        nextView.detailItem = object
                        nextView.key = realIndex
                    }
                }
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        let object = objects[indexPath.row] as! NSDictionary
        
        cell.textLabel?.text = object.valueForKey("name") as? String
        cell.detailTextLabel?.text = object.valueForKey("date") as? String
        
        cell.backgroundColor = UIColor(red: 5.0/255, green: 51.0/255, blue: 103.0/255, alpha: 1.0)
        
        return cell
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
    
    
    @IBAction func loadTable() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        dispatch_async(dispatch_get_main_queue(), {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
        
        // Check if it's a reload
        if self.reload {
            self.objects.removeAllObjects()
            tableView.reloadData()
        } else {
            self.reload = true
        }
        
        // Load original script to refresh
        if let url: NSURL = NSURL(string: "https://script.google.com/macros/s/AKfycbxHk_GXziSAwSH6umVyz3LnnbgpkA9BnqvL2ILeFdhdUkLKobg/exec") {
            let session = NSURLSession.sharedSession()
            let dataTask = session.dataTaskWithURL(url, completionHandler: nil)
            dataTask.resume()
        }
        
        if let data = getData() {
            self.pulledData = data
            for i in data {
                if let event: NSDictionary = i.value as? NSDictionary {
                    if let name: String = event.valueForKey("pretty_name") as? String {
                        if let date: NSDictionary = event.valueForKey("date") as? NSDictionary {
                            if let month: Int = date.valueForKey("month") as? Int {
                                if let day: Int = date.valueForKey("day") as? Int {
                                    if let year: Int = date.valueForKey("year") as? Int {
                                        let date: String = "\(month)/\(day)/\(year)"
                                        insertNewObject(name, date: date)
                                        tags[name as String] = i.key as? String
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            alert("No Connection", withMessage: "The Key Club app requires an Internet connection to function properly.", toView: self)
        }
    }
    
    func loadIcons() {
        let announcementButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Announcements_Large"), landscapeImagePhone: UIImage(named: "Announcements_Small"), style: UIBarButtonItemStyle.Plain, target: self, action: "loadInfo")
        announcementButton.tintColor = UIColor.blackColor()
        
        let refreshButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "loadTable")
        
        let rightButtons: [UIBarButtonItem] = [refreshButton, announcementButton]
        self.navigationItem.rightBarButtonItems = rightButtons
        
        let profButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Profile_Large"), landscapeImagePhone: UIImage(named: "Profile_Small"), style: UIBarButtonItemStyle.Plain, target: self, action: "goToProf")
        profButton.tintColor = UIColor.blackColor()
        profButton.width = -1.0 // Remove auto-sizing
        
        self.navigationItem.leftBarButtonItems = [self.settingsButton, profButton]
        
        self.noButtons = false
    }
    
    func loadInfo() {
        self.performSegueWithIdentifier("loadInfo", sender: self)
    }
    
    func goToSettings() {
        self.performSegueWithIdentifier("goToSettings", sender: self)
    }
    
    func goToProf() {
        self.performSegueWithIdentifier("goToProfile", sender: self)
    }
}

/**
Present a UIAlert using a UIAlertViewController (iOS 8+) or UIAlertView (iOS 7).

:param: title Title of the alert.
:param: withMessage Message body of the alert.
:param: toView View on which to present the alert.
*/

public func alert(title: String, withMessage message: String, toView sender: UIViewController) {
    if let gotModernAlert: AnyClass = NSClassFromString("UIAlertController") {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action: UIAlertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        sender.presentViewController(alert, animated: true, completion: nil)
        
    } else {
        let alert: UIAlertView = UIAlertView()
        alert.delegate = sender
        
        alert.title = title
        alert.message = message
        alert.addButtonWithTitle("OK")
        
        alert.show()
        
    }
}

/**
Checks whether a user is logged into the Key Club app.

:returns: Boolean value indicating whether the user is logged in.
*/
public func isLoggedIn() -> Bool {
    if let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.Key-Club") {
        if let loggedUser: String = defaults.valueForKey("name") as? String {
            return true
        }
    }
    return false
}