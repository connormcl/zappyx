//
//  SignUpViewController.swift
//  PushChat
//
//  Created by Connor McLaughlin on 7/26/15.
//  Copyright (c) 2015 Connor McLaughlin. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    func displayAlertMessage(alertTitle:String, alertDescription:String) -> Void {
        // hide activityIndicator view and display alert message
        // self.activityIndicatorView.hidden = true
        let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
    
    @IBAction func signupBtnTapped(sender: AnyObject) {
        // Code to hide the keyboards for text fields
        if self.firstNameField.isFirstResponder() {
            self.firstNameField.resignFirstResponder()
        }
        if self.lastNameField.isFirstResponder() {
            self.lastNameField.resignFirstResponder()
        }
        if self.emailField.isFirstResponder() {
            self.emailField.resignFirstResponder()
        }
        if self.passwordField.isFirstResponder() {
            self.passwordField.resignFirstResponder()
        }
        // validate presence of required parameters
        if !(count(self.firstNameField.text) > 0
            && count(self.lastNameField.text) > 0
            && count(self.emailField.text) > 0
            && count(self.passwordField.text) > 0) {
            self.displayAlertMessage("Parameters Required", alertDescription: "Some of the required parameters are missing")
            return
        }
        
        var request = NSMutableURLRequest(URL: NSURL(string: "http://pushchat.rails.connormclaughlin.net/api/signup")!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let deviceToken : String
        
        if let token = defaults.stringForKey("deviceToken") {
            deviceToken = token
        } else {
            self.displayAlertMessage("Error", alertDescription: "Failed to create account: could not read device token")
            return
        }
        
        var params = ["first_name":"\(self.firstNameField.text)", "last_name":"\(self.lastNameField.text)", "email":"\(self.emailField.text)", "password":"\(self.passwordField.text)", "device_token":"\(deviceToken)"] as Dictionary<String, String>
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                self.displayAlertMessage("Error", alertDescription: "Failed to create account")
                return
            }
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)!
            println("Body: \(strData)")
            
            let json = JSON(data: data, options: nil, error: nil)
            
            var errorsList = ""
            
            for(key: String, e: JSON) in json["errors"] {
                println(key)
                println(e[0])
                var cKey = key
                cKey.replaceRange(cKey.startIndex...cKey.startIndex, with: String(cKey[cKey.startIndex]).capitalizedString)
                if count(errorsList) > 0 {
                    errorsList.extend("\n" + cKey + " " + e[0].string!)
                } else {
                    errorsList.extend(cKey + " " + e[0].string!)
                }
            }
            if count(errorsList) > 0 {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.displayAlertMessage("Errors", alertDescription: errorsList)
                })
                return
            }
            if let e = json["error"].string {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.displayAlertMessage("Error", alertDescription: e)
                })
                return
            }
            if let token = json["token"].string {
                defaults.setObject(token, forKey: "apiKey")
            }
            defaults.setBool(true, forKey: "loggedInFlag")
            if let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("mainVC") as? ViewController {
                self.presentViewController(viewController, animated: true, completion: nil)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.displayAlertMessage("Success", alertDescription: "Account successfully created")
            })
        })
        
        task.resume()
//        
//        // start activity indicator
//        // self.activityIndicatorView.hidden = false
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
