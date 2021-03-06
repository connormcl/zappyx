//
//  PhotosList.swift
//  PushChat
//
//  Created by Connor McLaughlin on 8/8/15.
//  Copyright (c) 2015 Connor McLaughlin. All rights reserved.
//

import UIKit

class PhotosList: UITableViewController {
    var json : JSON = []
    @IBOutlet var photosListTableView: UITableView!
    
    func displayAlertMessage(alertTitle:String, alertDescription:String) -> Void {
        // hide activityIndicator view and display alert message
        // self.activityIndicator.hidden = true
        let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
    
    override func viewWillAppear(animated: Bool) {
        var request = NSMutableURLRequest(URL: NSURL(string: "http://pushchat.rails.connormclaughlin.net/api/unopened_photos")!)
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
                self.photosListTableView.reloadData()
            })
        })
        
        task.resume()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.photosListTableView.cellForRowAtIndexPath(indexPath) as! PhotoCell
        let photo_id = json["unopened_photos"][indexPath.row].string!
        let fileManager = NSFileManager.defaultManager()
        
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var photoPath = "\(paths)/\(photo_id).jpg"
        
        if (fileManager.fileExistsAtPath(photoPath)) {
            println("FILE AVAILABLE");
            
            var photo : UIImage = UIImage(contentsOfFile: photoPath)!
            cell.photo = photo
            
            if let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("photoDisplay") as? PhotoDisplayViewController {
                self.presentViewController(viewController, animated: false, completion: nil)
                viewController.imageView.image = cell.photo
            }
            return
        }
        else
        {
            println("FILE NOT AVAILABLE");
        }
        
        var request = NSMutableURLRequest(URL: NSURL(string: "http://pushchat.rails.connormclaughlin.net/api/get_photo?photo_id=\(photo_id)")!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let apiKey = defaults.objectForKey("apiKey") as! String
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        cell.activityIndicator.hidden = false
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.displayAlertMessage("Error", alertDescription: "Failed to load photo")
                    cell.activityIndicator.hidden = true
                })
                return
            }
//            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)!
//            
//            self.json = JSON(data: data, options: nil, error: nil)
//            
//            
//            if let e = self.json["error"].string {
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.displayAlertMessage("Error", alertDescription: e)
//                })
//                return
//            }
            fileManager.createFileAtPath(photoPath, contents: data, attributes: nil)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.photo = UIImage(data: data)
                cell.activityIndicator.hidden = true
            })
        })
        
        task.resume()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return json["unopened_photos"].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        let photo_id = json["unopened_photos"][indexPath.row].string!
        cell.senderNameLabel.text = "Photo ID: \(photo_id)"
        let fileManager = NSFileManager.defaultManager()
        
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var photoPath = "\(paths)/\(photo_id).jpg"
        
        if (fileManager.fileExistsAtPath(photoPath)) {
            println("FILE AVAILABLE");
            
            var photo : UIImage = UIImage(contentsOfFile: photoPath)!
            cell.photo = photo
        }
        else
        {
            println("FILE NOT AVAILABLE");
        }
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
