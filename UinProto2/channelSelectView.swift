//
//  channelSelectView.swift
//  Uin
//
//  Created by Kareem Dasilva on 4/16/15.
//  Copyright (c) 2015 Kareem Dasilva. All rights reserved.
//

import UIKit

class channelSelectView: UITableViewController {
    
    //Channel Sections
    var channels = [String]()
    var channelNames = [String]()
    var channelType = [String]()
    //General Channels
    var genChannels = ["Local Event", "Subscriptions", "Trending Events"]
    var gentype = ["localEvent","subbedEvents","trending"]
    //Sections
   //User Section
    var userType = [String]()
    var usernameInfo = [String]()
     var usernameSectionTitle = [String]()
   
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
        getChannels()
        
    }
    func getChannels(){
        var channelQuery = PFQuery(className: "ChannelUser")
        channelQuery.whereKey("userID", equalTo: PFUser.currentUser().objectId)
        channelQuery.findObjectsInBackgroundWithBlock({
            (results: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for object in results {
                    self.channels.append(object["channelID"] as! String)
                    self.channelNames.append(object["channelName"] as! String)
                    self.channelType.append("channelSelect")
                    println(object["channelID"] as! String)
                }
                self.tableView.reloadData()
            }
        })
    }
    func getUserInfo(){
        usernameInfo.append("") //Gets the Username
        usernameSectionTitle.append(PFUser.currentUser().username)
        userType.append("profile")
        var subscriberInfo = PFQuery(className: "Subscription") //gets the subcsriber count
        subscriberInfo.whereKey("subscriber", equalTo: PFUser.currentUser().username)
        usernameInfo.append(String(subscriberInfo.countObjects()))
        usernameSectionTitle.append("Subscribers")
        userType.append("Subscribers")
        
        var subscriptionInfo = PFQuery(className: "Subscription") //gets the subscription count
        subscriptionInfo.whereKey("publisher", equalTo: PFUser.currentUser().username)
        usernameInfo.append(String(subscriptionInfo.countObjects()))
        usernameSectionTitle.append("Subscriptions")
        userType.append("Subscriptions")
        
        var notificationsCount = PFQuery(className: "Notification")
        notificationsCount.whereKey("receiver", equalTo: PFUser.currentUser().username)
        usernameInfo.append(String(notificationsCount.countObjects()))
        usernameSectionTitle.append("Notifications")
        userType.append("Notifications")
        /*var addToCalendarCount = PFQuery(className: "UserCalendar")
        notificationsCount.whereKey("receiver", equalTo: PFUser.currentUser().username)
        usernameInfo.append(String(notificationsCount.countObjects()))
        */
        usernameInfo.append("3")
        usernameSectionTitle.append("My Events")
        userType.append("My Events")
    }
    func getLocalChannel(){
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var totalSections = usernameSectionTitle +  genChannels + channelNames
       
        return totalSections.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       var totalSections = usernameSectionTitle +  genChannels + channelNames
        var cell:channelTableCell = tableView.dequeueReusableCellWithIdentifier("profile") as! channelTableCell
     //   cell.channelCount.text = usernameInfo[indexPath.row]
        cell.channelName.text = totalSections[indexPath.row]
        cell.channelName.tag = indexPath.row
    
      
        return cell
        
    }



    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         var allTypes = userType + gentype + channelType
        switch allTypes[indexPath.row] {
            case "Subscriptions":
            self.performSegueWithIdentifier("Subscriptions", sender: self)
            break
        case "Subscribers":
            self.performSegueWithIdentifier("Subscribers", sender: self)
            break
        case "Notifications":
            self.performSegueWithIdentifier("Notifications", sender: self)
            break
        case "My Events":
            self.performSegueWithIdentifier("My Events", sender: self)
        case "localEvent":
            self.performSegueWithIdentifier("channelSelect", sender: self)
            break
        case "subbedEvents":
            self.performSegueWithIdentifier("channelSelect", sender: self)
            break
        case "trending":
            self.performSegueWithIdentifier("channelSelect", sender: self)
            break
        case "channelSelect":
            self.performSegueWithIdentifier("channelSelect", sender: self)
            break

        default:
            break
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
   
        if segue.identifier == "channelSelect" {
              var allInfo = usernameInfo + gentype + channels
            var indexPath = tableView.indexPathForSelectedRow()
            let nav = segue.destinationViewController as! UINavigationController
            let eventFeed:eventFeedViewController = nav.topViewController as! eventFeedViewController
            var row = indexPath?.row
            println(allInfo[row!])
            eventFeed.channelID = allInfo[row!]
            
        }
    }


}

