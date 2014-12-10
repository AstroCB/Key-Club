//
//  DetailViewController.swift
//  Key Club
//
//  Created by Cameron Bernhardt on 11/20/14.
//  Copyright (c) 2014 Cameron Bernhardt. All rights reserved.
//

import UIKit
import Foundation

extension String {
    public func split(separator: String) -> [String] {
        if separator.isEmpty {
            return map(self) { String($0) }
        }
        if var pre = self.rangeOfString(separator) {
            var parts = [self.substringToIndex(pre.startIndex)]
            while let rng = self.rangeOfString(separator, range: pre.endIndex..<endIndex) {
                parts.append(self.substringWithRange(pre.endIndex..<rng.startIndex))
                pre = rng
            }
            parts.append(self.substringWithRange(pre.endIndex..<endIndex))
            return parts
        } else {
            return [self]
        }
    }
}

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailName: UINavigationItem!
    var curEvent: NSDictionary = NSDictionary()
    var key: String = ""
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var chairs: UILabel!

    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var details: UITextView!
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
            if let label = self.eventDescription {
                // Set view name
                self.tabBarController?.navigationItem.title = self.curEvent.valueForKey("pretty_name") as? String
                
                // Set date
                if let date: NSDictionary = self.curEvent.valueForKey("date") as? NSDictionary {
                    if let month: Int = date.valueForKey("month") as? Int {
                        let day: Int = date.valueForKey("day") as Int
                        let year: Int = date.valueForKey("year") as Int
                        self.eventDescription.text = "\(month)/\(day)/\(year)"
                    }
                }
                
                // Set chairs
                if let evtChairs: String = self.curEvent.valueForKey("chairs") as? String {
                    var chairStr: String = ""
                    let chairArr: [String] = evtChairs.split(", ")
                    for var i = 0; i < chairArr.count; i++ {
                        chairStr += "\(chairArr[i])\n"
                        chairs.numberOfLines++
                    }
                    chairs.text = chairStr
                }
                
                // Set details
                
                if let description: String = self.curEvent.valueForKey("desc") as? String {
                    self.details.text = description
                } else {
                    self.details.text = "-"
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

