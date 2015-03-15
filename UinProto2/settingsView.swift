//
//  settingsView.swift
//  UinProto2
//
//  Created by Kareem Dasilva on 2/15/15.
//  Copyright (c) 2015 Kareem Dasilva. All rights reserved.
//

import UIKit

class settingsView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var user = PFUser.currentUser()
        println()
        println()
        if user != nil {
        
        if user["push"] as Bool == true {
           notifySlider.setOn(true, animated: true)
        }   else {
            notifySlider.setOn(false, animated: true)
            }
        }   else {
            self.navigationItem.rightBarButtonItem?.title = "Create account"
            notifySlider.enabled = false
        }
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navBarBackground.png"), forBarMetrics: UIBarMetrics.Default)
        // Changes text color on navbar
        var nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()];
        self.tabBarController?.tabBar.hidden = true
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet var notifySlider: UISwitch!
    @IBAction func notifySwitch(sender: AnyObject) {
        
        var user = PFUser.currentUser()
        if notifySlider.on == true {
            var subscriptionUsernames = [String]()
            var user = PFUser.currentUser()
            user["push"] = true
            user.save()
            var query = PFQuery(className: "Subs")
            query.whereKey("follower", equalTo: PFUser.currentUser().username)
            query.findObjectsInBackgroundWithBlock({
        
                (objects:[AnyObject]!, queError:NSError!) -> Void in

                if queError == nil {
                    println(subscriptionUsernames)
                    for object in objects {
                        subscriptionUsernames.append(object["userId"] as String)
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
            user["push"] = false
            user.save()
        }
        
    }
    
    @IBAction func logout(sender: AnyObject) {
        
       println("you pressed it")
        
        // Removex your installations channels and logs outs
        if PFUser.currentUser() != nil {
       // var install = PFInstallation.currentInstallation()
        //var channels = install.channels
          //  if channels == nil {
            //    PFUser.logOut()
            //}
        //install.removeObjectsInArray(channels, forKey: "channels")
        //install.save()
        PFUser.logOut()
         self.performSegueWithIdentifier("logout", sender: self)
        }   else {
            self.performSegueWithIdentifier("logout", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


