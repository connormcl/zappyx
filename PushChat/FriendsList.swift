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
    var capturedImage : UIImage!
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
    
    /// Create boundary string for multipart/form-data request
    ///
    /// :returns:            The boundary string that consists of "Boundary-" followed by a UUID string.
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
        
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let apiKey = defaults.objectForKey("apiKey") as! String
        let recipient_id = String(json["users"][indexPath.row]["id"].int!)
        var imgData = UIImageJPEGRepresentation(self.capturedImage, 0.7)
        let boundary = generateBoundaryString()
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://pushchat.rails.connormclaughlin.net/api/send_photo")!)
        request.HTTPMethod = "POST"
        
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let bodyParams : NSMutableData = NSMutableData()
        
        // build and format HTTP body with data
        // prepare for multipart form uplaod
        
        let boundaryString = "--\(boundary)\r\n"
        let boundaryData = boundaryString.dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        bodyParams.appendData(boundaryData)
        
        // set the parameter name
        let imageMetaData = "Content-Disposition: attachment; name=\"photo\"; filename=\"photo.jpg\"\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(imageMetaData!)
        
        // set the content type
        let fileContentType = "Content-Type: image/jpeg\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(fileContentType!)
        
        // add the actual image data
        bodyParams.appendData(imgData)
        
        let imageDataEnding = "\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(imageDataEnding!)
        
        let boundaryString2 = "--\(boundary)\r\n"
        let boundaryData2 = boundaryString.dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        
        bodyParams.appendData(boundaryData2)
        
        // pass the recipient_id of the photo
        let formData = "Content-Disposition: form-data; name=\"recipient_id\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(formData!)
        
        let formData2 = recipient_id.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(formData2!)
        
        let closingFormData = "\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        bodyParams.appendData(closingFormData!)
        
        let closingData = "--\(boundary)--\r\n"
        let boundaryDataEnd = closingData.dataUsingEncoding(NSUTF8StringEncoding) as NSData!
        
        bodyParams.appendData(boundaryDataEnd)
        
        request.HTTPBody = bodyParams
        
        var task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.displayAlertMessage("Error", alertDescription: "Failed to send message")
                })
                return
            }
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)!
            println("Body: \(strData)")
            
            let json = JSON(data: data, options: nil, error: nil)
            
            if let e = json["error"].string {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.displayAlertMessage("Error", alertDescription: e)
                })
                return
            }
            if let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("mainVC") as? ViewController {
                self.presentViewController(viewController, animated: true, completion: nil)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.displayAlertMessage("Success", alertDescription: "Message sent!")
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
