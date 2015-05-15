//
//  settingsView.swift
//  UinProto2
//
//  Created by Kareem Dasilva on 2/15/15.
//  Copyright (c) 2015 Kareem Dasilva. All rights reserved.
//

import UIKit

class settingsView: UIViewController {

    @IBOutlet weak var emailBtn: UIButton!
    @IBOutlet var menuTrigger: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        var theMix = Mixpanel.sharedInstance()
        theMix.track("Settings Opened")
        theMix.flush()
        
        var user = PFUser.currentUser()
        //Checks if the user has verified the email
        if user["emailVerified"] != nil {
            if user["emailVerified"] as! Bool == true {
                emailBtn.enabled = false //disables if user alreadies has email verifications
            } else {
                self.emailBtn.enabled = true
            }
        } else {
            //enable if the user has a "nil" value for emailverifed
            emailBtn.enabled = true
        }
      
        if user["pushEnabled"] as!Bool == true {
            notifySlider.setOn(true, animated: true)
        }   else {
             notifySlider.setOn(false, animated: true)
        }
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navBarBackground.png"), forBarMetrics: UIBarMetrics.Default)
        // Changes text color on navbar
        var nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()];
        self.tabBarController?.tabBar.hidden = true
       
        // Do any additional setup after loading the view.
        if self.revealViewController() != nil {
            menuTrigger.target = self.revealViewController()
            menuTrigger.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
                self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
    }
    
    @IBOutlet var notifySlider: UISwitch!
    @IBAction func notifySwitch(sender: AnyObject) {
        var theMix = Mixpanel.sharedInstance()
        theMix.track("Notifications Off/On (S)")
        theMix.flush()
        
        var user = PFUser.currentUser()
        if notifySlider.on == true {
            var subscriptionUsernames = [String]()
            var user = PFUser.currentUser()
            user["pushEnabled"] = true
            user.save()
            var query = PFQuery(className: "Subscription")
            query.whereKey("subscriberID", equalTo: PFUser.currentUser().objectId)
            query.findObjectsInBackgroundWithBlock({
        
                (objects:[AnyObject]!, queError:NSError!) -> Void in

                if queError == nil {
                    println(subscriptionUsernames)
                    for object in objects {
                        subscriptionUsernames.append(object["publisherID"] as!String)
                    }
                        var user = PFUser.currentUser()
                        var currentInstallation = PFInstallation.currentInstallation()
                        currentInstallation.setValue(subscriptionUsernames, forKey: "channels")
                        currentInstallation.save()
                }
            })
        }
        else {
            var install = PFInstallation.currentInstallation()
            var channels = install.channels
            if channels != nil {
                install.removeObjectsInArray(channels, forKey: "channels")
                install.save()

            }
            var user = PFUser.currentUser()
            user["pushEnabled"] = false
            user.save()
        }
        
    }
    
    @IBAction func logout(sender: AnyObject) {
        var theMix = Mixpanel.sharedInstance()
        theMix.track("Logout (S)")
        theMix.flush()
        
       println("you pressed it")
        var install = PFInstallation.currentInstallation()
        var channels = install.channels
        if channels == nil {
            PFUser.logOut()
            self.performSegueWithIdentifier("logout", sender: self)
        } else {
            install.removeObjectsInArray(channels, forKey: "channels")
            install.save()
            PFUser.logOut()
            self.performSegueWithIdentifier("logout", sender: self)
        }
 

    }
    //Forces an email verification
    @IBAction func resendEmail(sender: AnyObject) {
        PFUser.currentUser().email = PFUser.currentUser().email
        PFUser.currentUser().save()
    }
   
    //Changes the type
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "email" {
            var accountInfoChangeView:ChangeAccountInfo = segue.destinationViewController as! ChangeAccountInfo
            accountInfoChangeView.accountChangeType = "email"
        }
        if segue.identifier == "password" {
            var accountInfoChangeView:ChangeAccountInfo = segue.destinationViewController as! ChangeAccountInfo
            accountInfoChangeView.accountChangeType = "password"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
class ChangeAccountInfo: UIViewController {
    
    @IBOutlet weak var newTokenField: UITextField!
    @IBOutlet weak var newToken: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var changeToken: UILabel!
    @IBOutlet weak var confirmToken: UILabel!
    @IBOutlet weak var sendTokenBtn: UIButton!
    @IBOutlet weak var resultToken: UILabel!
    
    
    var accountChangeType = (String)() //What type of account changing it is
    
    @IBAction func sendToken(sender: AnyObject) {
        //Sends an password reset fourm if email are both correct
        if accountChangeType == "password" {
            if confirmTextField.text == PFUser.currentUser().email && passwordTextField.text == PFUser.currentUser().email {
                //Saves newTokenField to the current users password
                PFUser.requestPasswordResetForEmailInBackground(newTokenField.text, block: {
                    (success:Bool, error:NSError!) -> Void in
                    if error == nil {
                        self.resultToken.text = "Password Reset Sent"
                        self.sendTokenBtn.setTitle("Resend", forState: UIControlState.Normal)
                    } else {
                        self.resultToken.text = "Invalid Email address"
                    }
                })
            } else {
                self.resultToken.text = "Email address not found"
            }

        }
        //Changes email and also resends the email verification if the user is not verified
        if accountChangeType == "email" {
            if confirmTextField.text == PFUser.currentUser().email && passwordTextField.text == PFUser.currentUser().email {
                //Saves newTokenField to the current users password
                PFUser.currentUser().email = newTokenField.text
                PFUser.currentUser().saveInBackgroundWithBlock({
                    (sucess:Bool, error:NSError!) -> Void in
                    if error == nil {
                        self.resultToken.text = "Email is now changed"
                    } else {
                        self.resultToken.text = "Error changing password try again"
                        println(error.debugDescription)
                    }
                })
            }    else {
                self.resultToken.text = "Email address not found"
            }
            
           
        }
    }
    //Changes text, placeholder, and Ui depening on what type of change the view provides
    func setupChangeInfo(){
        if accountChangeType == "email" {
            self.navigationItem.title = "Change Email"
            newTokenField.placeholder = "enter new email address"
            changeToken.text = "Enter Current Email"
            resultToken.text = ""
            confirmToken.text = "Confirm Email"
            sendTokenBtn.setTitle("Change Email", forState: UIControlState.Normal)
        }
        if accountChangeType == "password" {
             self.navigationItem.title = "Reset Password"
            newTokenField.placeholder = "enter email"
            changeToken.text = "Confirm email"
            confirmToken.text = "Confirm Password"
            resultToken.text = ""
            sendTokenBtn.setTitle("Password Reset", forState: UIControlState.Normal)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
    }
    override func viewWillAppear(animated: Bool) {
        setupChangeInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


