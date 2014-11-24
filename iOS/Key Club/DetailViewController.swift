//
//  DetailViewController.swift
//  Key Club
//
//  Created by Cameron Bernhardt on 11/20/14.
//  Copyright (c) 2014 Cameron Bernhardt. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailName: UINavigationItem!
    var curEvent: NSDictionary = NSDictionary()
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var chairs: UILabel!

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
                self.detailName.title = curEvent.valueForKey("pretty_name") as? String
                if let date: NSDictionary = curEvent.valueForKey("date") as? NSDictionary {
                    if let month: AnyObject = date.valueForKey("month") {
                        if let day: AnyObject = date.valueForKey("day") {
                            if let year: AnyObject = date.valueForKey("year") {
                                self.eventDescription.text = "\(month)/\(day)/\(year)"
                            }
                        }
                    }
                }
                if let evtChairs: String = self.curEvent.valueForKey("chairs") as? String {
                    chairs.text = evtChairs
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

