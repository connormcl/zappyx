//
//  ViewController.swift
//  PushChat
//
//  Created by Connor McLaughlin on 7/24/15.
//  Copyright (c) 2015 Connor McLaughlin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        checkLoggedIn()
    }
    
    func checkLoggedIn() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.boolForKey("loggedInFlag") != true {
            println("should be segueing now")
            self.performSegueWithIdentifier("checkLoggedIn", sender: nil)
        }
    }
    
    @IBAction func logOut(sender: AnyObject) {
        if let loginController = self.storyboard?.instantiateViewControllerWithIdentifier("logInVC") as? UIViewController {
            self.showViewController(loginController, sender: nil)
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(false, forKey: "loggedInFlag")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

