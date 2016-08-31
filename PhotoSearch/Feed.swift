//
//  Feed.swift
//  PhotoFeed
//
//  Created by Mike Spears on 2016-01-08.
//  Copyright © 2016 YourOganisation. All rights reserved.
//

import Foundation



func fixJsonData (data: NSData) -> NSData {
    var dataString = String(data: data, encoding: NSUTF8StringEncoding)!
    dataString = dataString.stringByReplacingOccurrencesOfString("\\'", withString: "'")
    return dataString.dataUsingEncoding(NSUTF8StringEncoding)!
    
}


class Feed {
    
    var items: [FeedItem]
    let sourceURL: NSURL
    
    
    init (items newItems: [FeedItem], sourceURL newURL: NSURL) {
        self.items = newItems
        self.sourceURL = newURL
    }
    
    convenience init? (data: NSData, sourceURL url: NSURL) {
        
        var newItems = [FeedItem]()
        
        let fixedData = fixJsonData(data)
        
        var jsonObject: Dictionary<String, AnyObject>?
        
        do {
            jsonObject = try NSJSONSerialization.JSONObjectWithData(fixedData, options: NSJSONReadingOptions(rawValue: 0)) as? Dictionary<String,AnyObject>
        } catch {
            
        }
        
        guard let feedRoot = jsonObject else {
            return nil
        }
        
        guard let items = feedRoot["items"] as? Array<AnyObject>  else {
            return nil
        }
        
        
        for item in items {
            
            guard let itemDict = item as? Dictionary<String,AnyObject> else {
                continue
            }
            guard let media = itemDict["media"] as? Dictionary<String, AnyObject> else {
                continue
            }
            
            guard let urlString = media["m"] as? String else {
                continue
            }
            
            guard let url = NSURL(string: urlString) else {
                continue
            }
            
            let title = itemDict["title"] as? String
            
            newItems.append(FeedItem(title: title ?? "(no title)", imageURL: url))
            
                       
        }
        
        self.init(items: newItems, sourceURL: url)
    }
    
    // read & save item list

    init () {
        self.sourceURL = NSURL(fileURLWithPath: "")
        self.items = [FeedItem]()
        // load items from file
        let path = feedFilePath()
        let unarchivedObject = NSKeyedUnarchiver.unarchiveObjectWithFile(path)
        //completion(feed: unarchivedObject as? Feed)
        if (unarchivedObject != nil) {
            self.items = unarchivedObject as! Array
        }

    }

    
    func feedFilePath() -> String {
        let paths = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        let filePath = paths[0].URLByAppendingPathComponent("feedFile.plist")
        //print(filePath.absoluteString)
        return filePath.path!
    }
    
    func saveItems() -> Bool {
        let success = NSKeyedArchiver.archiveRootObject(self.items, toFile: feedFilePath())
        assert(success, "failed to write archive")
        return success
    }
   /*
    func loadItems() {
        let path = feedFilePath()
        let unarchivedObject = NSKeyedUnarchiver.unarchiveObjectWithFile(path)
        //completion(feed: unarchivedObject as? Feed)
        if (unarchivedObject != nil) {
            self.items = unarchivedObject as! Array
        }
    }
    */
    func addItem(item: FeedItem) {
        //loadItems()
        
        // if item exist, remove it
        for index in 0..<self.items.count  {
            if item.imageURL.absoluteString == self.items[index].imageURL.absoluteString {
                self.items.removeAtIndex(index)
                break
            }
        }
        
        // insert at the first of items
        self.items.insert(item, atIndex: 0)
        
        saveItems()
        
//        for item in self.items {
//            print(item.imageURL.absoluteString)
//        }

    }
    
    func removeItem(index: Int) {
        self.items.removeAtIndex(index)
        saveItems()
    }
        
   
    
    
}