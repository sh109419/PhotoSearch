//
//  ViewController.swift
//  PhotoSearch
//
//  Created by hyf on 16/8/23.
//  Copyright © 2016年 hyf. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    // search bar var
    @IBOutlet weak var SearchTextField: UITextField!
    @IBOutlet weak var SearchButton: UIButton!
    // tableview var
    @IBOutlet weak var tableView: UITableView!
    // data & run var
    var feed: Feed? {
        didSet {
            print("feed didSet")
            tableView.reloadData()
        }
    }
    
    var urlSession: NSURLSession!
    
    // view controller functoin
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSThread.sleepForTimeInterval(2.0)// show launch screen
        
        setSearchTextField()
        setTableView()
        restoreData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.urlSession = NSURLSession(configuration: configuration)
        
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
        destination.feedItem = self.feed?.items[indexPath.row]
        
    }

    // init tableview
    func setTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    

    // init search text field
    func setSearchTextField() {
        SearchTextField.placeholder = "Photo tag"
        //SearchTextField.borderStyle = UITextBorderStyle.RoundedRect
        SearchTextField.backgroundColor = UIColor.lightGrayColor()
        //SearchTextField.layer.borderWidth = 1
        //SearchTextField.layer.borderColor = UIColor.blueColor().CGColor
        SearchTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
        SearchTextField.returnKeyType = UIReturnKeyType.Search
        SearchTextField.delegate = self
    }
    
    // restore data
    func restoreData() {
        let history = NSUserDefaults.standardUserDefaults().objectForKey("SearchHistory") as? [String]
        if history != nil && history?.count > 0 {
            let text = history![0]
            doPhotoSearch(text)
            SearchTextField.text = text
        }
    }
    
    // search button action
    @IBAction func onSearch(sender: AnyObject) {
        guard var text = SearchTextField.text else { return }
        
        // remvoe space
        text = text.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        SearchButton.enabled = false
        doPhotoSearch(text)
        saveSearchHistory(text)
    }
    
    func doPhotoSearch(text: String) {
       /* read json from file
        var path: String = NSBundle.mainBundle().pathForResource("photos_pig_public.gne", ofType: "js")!
        var nsUrl = NSURL(fileURLWithPath: path)
        var nsData: NSData = NSData(contentsOfURL: nsUrl)!
        let feed = Feed(data: nsData, sourceURL: nsUrl)
        
        self.feed = feed
*/

        print("do photo search:\(text)")

        let foundURLString = "https://api.flickr.com/services/feeds/photos_public.gne?tags=\(text)&format=json&nojsoncallback=1"
        
         if let url = NSURL(string: foundURLString) {
            updateFeed(url, completion: { (feed) -> Void in
                self.feed = feed
            })
         }
    }
    
    func updateFeed(url: NSURL, completion: (feed: Feed?) -> Void) {
        
        let request = NSURLRequest(URL: url)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error == nil && data != nil {
                let feed = Feed(data: data!, sourceURL: url)
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    completion(feed: feed)
                })
            }
            
        }
        
        task.resume()
        print("update feed")
    }
    
    func saveSearchHistory(text: String) {
        let history = NSUserDefaults.standardUserDefaults().objectForKey("SearchHistory") as? [String]
        var hasHistory = [String]()
        if history != nil  {
            hasHistory = history!
        }
        
        // if item exist, remove it, than insert new one
        let index = hasHistory.indexOf(text)
        if index == 0 {
            // do nothing
        } else if index > 0 {
            hasHistory.removeAtIndex(index!)
            hasHistory.insert(text, atIndex: 0)
        } else {
            hasHistory.insert(text, atIndex: 0)
        }
        

        NSUserDefaults.standardUserDefaults().setObject(hasHistory, forKey: "SearchHistory")
    }
    
}

// UITextFieldDelegate

extension MainViewController: UITextFieldDelegate {
    //bing delegate to viewcontroller
    
    func textFieldShouldReturn(textField:UITextField) -> Bool
    {
        //restore keyboard
        textField.resignFirstResponder()
        
        //do my job
        onSearch(self)
        
        return true;
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        SearchButton.enabled = true
        
        return true
    }
    
   
}

// UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return self.feed?.items.count ?? 0

    }

}

//UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    
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
    
}


