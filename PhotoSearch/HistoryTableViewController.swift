//
//  HistoryTableViewController.swift
//  PhotoSearch
//
//  Created by hyf on 16/8/30.
//  Copyright © 2016年 hyf. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    
    var history = [String]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let his = NSUserDefaults.standardUserDefaults().objectForKey("SearchHistory") as? [String]
        if his != nil  {
            history = his!
        }
        tableView.reloadData()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
              
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return history.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = history[indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        let text = cell?.textLabel?.text

        
        let destTabIndex = 0
        let destination = (self.tabBarController!.viewControllers![destTabIndex] as! UINavigationController).topViewController as! MainViewController
        destination.SearchTextField.text = text
        destination.onSearch(self)
        self.tabBarController?.selectedIndex = destTabIndex
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            history.removeAtIndex(indexPath.row)
            NSUserDefaults.standardUserDefaults().setObject(history, forKey: "SearchHistory")
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let indexPath = self.tableView.indexPathForSelectedRow!
       // let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! ImageFeedItemTableViewCell
        self.hidesBottomBarWhenPushed = false
        
        //let destination = segue.destinationViewController as! MainViewController
        //destination.hidesBottomBarWhenPushed = false
        let destination = (segue.destinationViewController as! UINavigationController).topViewController as! MainViewController
        
       // destination.inputImage = cell.itemImageView.image
       // destination.feedItem = self.feed!.items[indexPath.row]
    }
    */

}
