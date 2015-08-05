//
//  FriendsList.swift
//  PushChat
//
//  Created by Connor McLaughlin on 8/4/15.
//  Copyright (c) 2015 Connor McLaughlin. All rights reserved.
//

import UIKit

class FriendsList: UITableViewController {
    
    var json : JSON = []
    @IBOutlet var friendsListTableView: UITableView!
    
    func displayAlertMessage(alertTitle:String, alertDescription:String) -> Void {
        // hide activityIndicator view and display alert message
        // self.activityIndicator.hidden = true
        let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
    
    override func viewWillAppear(animated: Bool) {
        var request = NSMutableURLRequest(URL: NSURL(string: "http://pushchat.rails.connormclaughlin.net/api/get_users")!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let apiKey = defaults.objectForKey("apiKey") as! String
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.displayAlertMessage("Error", alertDescription: "Failed to load users")
                })
                return
            }
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)!
            
            self.json = JSON(data: data, options: nil, error: nil)
            
            
            if let e = self.json["error"].string {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.displayAlertMessage("Error", alertDescription: e)
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.friendsListTableView.reloadData()
            })
        })
        
        task.resume()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return json["users"].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = json["users"][indexPath.row]["email"].string!
        return cell
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
