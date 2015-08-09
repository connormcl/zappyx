//
//  ViewController.swift
//  PushChat
//
//  Created by Connor McLaughlin on 8/1/15.
//  Copyright (c) 2015 Connor McLaughlin. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    var stillImageOutput : AVCaptureStillImageOutput = AVCaptureStillImageOutput()
    var capturedImage: UIImage!
    
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var sendPhotoButton: UIButton!
    @IBOutlet weak var retakePhotoButton: UIButton!
    @IBOutlet weak var viewPhotosButton: UIButton!
    
    override func viewDidAppear(animated: Bool) {
        checkLoggedIn()
    }
    
    func setCameraActiveButtons() {
        self.takePhotoButton.hidden = false
        self.viewPhotosButton.hidden = false
        self.sendPhotoButton.hidden = true
        self.retakePhotoButton.hidden = true
    }
    
    func setCameraInactiveButtons() {
        self.takePhotoButton.hidden = true
        self.viewPhotosButton.hidden = true
        self.sendPhotoButton.hidden = false
        self.retakePhotoButton.hidden = false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        println("Capture device found")
                        beginSession()
                    }
                }
            }
        }
        setCameraActiveButtons()
    }
    
    @IBAction func retakePhoto(sender: AnyObject) {
        self.capturedImage = nil
        setCameraActiveButtons()
        
        self.captureSession.startRunning()
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        //        var videoConnection:AVCaptureConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        
        // we do this on another thread so that we don't hang the UI
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            //find the video connection
            var videoConnection : AVCaptureConnection?
            for connecton in self.stillImageOutput.connections {
                //find a matching input port
                for port in connecton.inputPorts!{
                    if port.mediaType == AVMediaTypeVideo {
                        videoConnection = connecton as? AVCaptureConnection
                        break //for port
                    }
                }
                
                if videoConnection  != nil {
                    break// for connections
                }
            }
            if videoConnection  != nil {
                self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {buffer, error -> Void in
                    if error != nil {
                        
                    }
                    if buffer == nil {
                        return
                    }
                    //println(buffer)
                    let imageDataJpeg = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                    self.capturedImage = UIImage(data: imageDataJpeg)!
                    self.captureSession.stopRunning()
                })
                //self.captureSession.stopRunning()
            }
        }
        setCameraInactiveButtons()
    }
    
    func beginSession() {
        var err : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        
        captureSession.addOutput(self.stillImageOutput)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //self.view.layer.addSublayer(previewLayer)
        self.view.layer.insertSublayer(previewLayer, atIndex: 0)
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "sendPhoto") {
            var svc = segue.destinationViewController as! FriendsList;
            
            svc.capturedImage = self.capturedImage
            println("captured image:")
            println(self.capturedImage)
        }
    }
}

