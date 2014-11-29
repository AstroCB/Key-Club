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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.clearsSelectionOnViewWillAppear = false
        loadTable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This fixes the odd issue where cells remain selected after using the left-to-right swipe gesture to return to the parent view controller
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let path: NSIndexPath = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(path, animated:animated)
        }
    }
    
    
    func insertNewObject(obj: AnyObject) {
        objects.insertObject(obj, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            /* This deselects the cell when clicked to avoid the persistent highlight issue
            It's a simpler solution, but fixing it rather than hiding it looks better */
            //                self.tableView.deselectRowAtIndexPath(indexPath, animated:true)
            
            let object: String = objects[indexPath.row] as String
            if let realIndex: String = tags[object] {
                let val: NSDictionary = pulledData.valueForKey(realIndex) as NSDictionary
                if let view: UITabBarController = segue.destinationViewController as? UITabBarController {
                    let views: [UIViewController] = (view.viewControllers as [UIViewController])
                    if let nextView: DetailViewController = views[0] as? DetailViewController{
                        nextView.curEvent = val
                        nextView.detailItem = object
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
        let object = objects[indexPath.row] as String
        cell.textLabel.text = object
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
    
    func loadTable() {
        if let data = getData() {
            pulledData = data
            for i in data {
                if let event: AnyObject = i.value as? NSDictionary {
                    if let name: AnyObject = event.valueForKey("pretty_name") {
                        insertNewObject(name)
                        tags[name as String] = i.key as? String
                    }
                }
            }
        } else {
            let alert: UIAlertController = UIAlertController(title: "No Connection", message: "The Key Club app requires an Internet connection to function properly.", preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
}