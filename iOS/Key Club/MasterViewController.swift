//
//  MasterViewController.swift
//  Key Club
//
//  Created by Cameron Bernhardt on 11/20/14.
//  Copyright (c) 2014 Cameron Bernhardt. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    var objects: NSMutableArray = NSMutableArray()
    var pulledData: NSDictionary = NSDictionary()
    var tags: [String: String] = [String: String]()
    var reload: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.clearsSelectionOnViewWillAppear = false
        loadTable()
        
        // Appearance of top bar
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        if let myriadPro: UIFont = UIFont(name: "Myriad Pro", size: 20){
            let attrDict: [NSObject: AnyObject] = [NSFontAttributeName: myriadPro]
            self.navigationController?.navigationBar.titleTextAttributes = attrDict
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
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
    }
    
    
    func insertNewObject(obj: AnyObject, date: String) {
        var dict: NSMutableDictionary = NSMutableDictionary()
        dict.setValue(obj, forKey: "name")
        dict.setValue(date, forKey: "date")
        
        objects.insertObject(dict, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            let dict: NSDictionary = objects[indexPath.row] as NSDictionary
            let object: String = dict.valueForKey("name") as String
            if let realIndex: String = tags[object] {
                let val: NSDictionary = pulledData.valueForKey(realIndex) as NSDictionary
                if let view: UITabBarController = segue.destinationViewController as? UITabBarController {
                    let views: [UIViewController] = (view.viewControllers as [UIViewController])
                    if let nextView: DetailViewController = views[0] as? DetailViewController{
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let object = objects[indexPath.row] as NSDictionary
        
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
        // Check if it's a reload
        if reload {
            objects.removeAllObjects()
            tableView.reloadData()
        } else {
            reload = true
        }
        
        // Load original script to refresh
        if let url: NSURL = NSURL(string: "https://script.google.com/macros/s/AKfycbxHk_GXziSAwSH6umVyz3LnnbgpkA9BnqvL2ILeFdhdUkLKobg/exec") {
            let session = NSURLSession.sharedSession()
            let dataTask = session.dataTaskWithURL(url, completionHandler: nil)
            dataTask.resume()
        }
        
        if let data = getData() {
            pulledData = data
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
            let alert: UIAlertController = UIAlertController(title: "No Connection", message: "The Key Club app requires an Internet connection to function properly.", preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
}