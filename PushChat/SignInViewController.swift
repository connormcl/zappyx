//
//  SignInViewController.swift
//  PushChat
//
//  Created by Connor McLaughlin on 7/31/15.
//  Copyright (c) 2015 Connor McLaughlin. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func displayAlertMessage(alertTitle:String, alertDescription:String) -> Void {
        // hide activityIndicator view and display alert message
        self.activityIndicator.hidden = true
        let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
    
    @IBAction func loginBtnTapped(sender: AnyObject) {
        // Code to hide the keyboards for text fields
        if self.emailField.isFirstResponder() {
            self.emailField.resignFirstResponder()
        }
        if self.passwordField.isFirstResponder() {
            self.passwordField.resignFirstResponder()
        }
        
        self.activityIndicator.hidden = false
        
        // validate presence of required parameters
        if !(count(self.emailField.text) > 0
            && count(self.passwordField.text) > 0) {
                self.displayAlertMessage("Parameters Required", alertDescription: "Some of the required parameters are missing")
                return
        }
        makeLogInRequest()
    }
    
    func makeLogInRequest(){
        var request = NSMutableURLRequest(URL: NSURL(string: "http://pushchat.rails.connormclaughlin.net/api/auth")!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        var params = ["email":"\(self.emailField.text)", "password":"\(self.passwordField.text)"] as Dictionary<String, String>
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.displayAlertMessage("Error", alertDescription: "Incorrect login credentials")
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
            if let token = json["token"].string {
                defaults.setObject(token, forKey: "apiKey")
            }
            defaults.setBool(true, forKey: "loggedInFlag")
            if let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("mainVC") as? ViewController {
                self.presentViewController(viewController, animated: true, completion: nil)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.displayAlertMessage("Success", alertDescription: "Login successful")
            })
        })
        
        task.resume()
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
