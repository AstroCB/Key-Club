//
//  LeaderboardViewController.swift
//  Key Club
//
//  Created by Cameron Bernhardt on 1/27/15.
//  Copyright (c) 2015 Cameron Bernhardt. All rights reserved.
//

import Foundation
import UIKit

class LeaderboardViewController: UIViewController {
    /// TextView that holds rankings.
    @IBOutlet weak var leaderList: UITextView!
    
    override func viewDidLoad() {
        if let req = NSData(contentsOfURL: NSURL(string: "https://api.myjson.com/bins/3hwwj")!){
            var error: NSError?
            if let JSON: NSDictionary = NSJSONSerialization.JSONObjectWithData(req, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
                if let leaderArr: [String] = JSON.valueForKey("0") as? [String] {
                    var leaderString: String = ""
                    for var i = 0; i < leaderArr.count; i++ {
                        leaderString += "\(i+1). \(leaderArr[i])\n\n"
                    }
                    leaderList.text = leaderString
                }
            }
        }
    }
}