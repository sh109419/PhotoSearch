//
//  ViewController.swift
//  PhotoSearch
//
//  Created by hyf on 16/8/23.
//  Copyright © 2016年 hyf. All rights reserved.
//

import UIKit

class ImageListViewController: UIViewController {

    // tableview var
   @IBOutlet weak var tableView: UITableView!
   
    // data & run var
    var feed: Feed?
    
    var urlSession: NSURLSession!
    
    // view controller functoin
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        /* why it not work here
        feed = Feed()
        setTableView()
        print("viewdidload") */

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.urlSession = NSURLSession(configuration: configuration)
        // 
        setTableView()
        feed = Feed()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.urlSession.invalidateAndCancel()
        self.urlSession = nil
    }

    // segue
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        let indexPath = self.tableView.indexPathForSelectedRow!
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! ImageFeedItemTableViewCell
        
        // no image no show
        if (cell.itemImageView.image == nil) { return false }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let indexPath = self.tableView.indexPathForSelectedRow!
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! ImageFeedItemTableViewCell
        //let destination = segue.destinationViewController as! ImageViewController
        let destination = (segue.destinationViewController as! UINavigationController).topViewController as! ImageViewController
        
        destination.inputImage = cell.itemImageView.image
        destination.feedItem = self.feed!.items[indexPath.row]
        
    }

    // init tableview
    func setTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    
}


// UITableViewDataSource

extension ImageListViewController: UITableViewDataSource {
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return self.feed!.items.count ?? 0

    }

}

//UITableViewDelegate

extension ImageListViewController: UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ImageFeedItemTableViewCell", forIndexPath: indexPath) as! ImageFeedItemTableViewCell
        
        let item = self.feed!.items[indexPath.row]
        cell.itemTitle.text = item.title
        
        let request = NSURLRequest(URL: item.imageURL)
      
        cell.dataTask = self.urlSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                if error == nil && data != nil {
                    let image = UIImage(data: data!)
                    cell.itemImageView.image = image
                }
            })
            
        }
        
        cell.dataTask?.resume()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? ImageFeedItemTableViewCell {
            cell.dataTask?.cancel()
        }
    }
    
    // delete row when left slip
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            // remove from dataset
            //self.feed!.items.removeAtIndex(indexPath.row)
            self.feed?.removeItem(indexPath.row)
            // remove from table
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.endUpdates()
        }
    }

    
    
}


