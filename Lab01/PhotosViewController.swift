//
//  PhotosViewController.swift
//  Lab01
//
//  Created by Sumedha Mehta on 6/16/16.
//  Copyright © 2016 Sumedha Mehta. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var table: UITableView!
    
    var posts: [NSDictionary] = []
    var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 240
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadData), forControlEvents: UIControlEvents.ValueChanged)
        
        loadData()
    }
    
    func loadData() {
        let url = NSURL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if let data = data {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data, options:[]) as? NSDictionary {
                    
                    let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                    
                    self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                }
                self.table.reloadData()
            }
            self.refreshControl?.endRefreshing()
        });
        task.resume()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.posts.count)
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell") as! PhotosCell
        let post = posts[indexPath.row]
        
        if let photos = post.valueForKey("photos") as? [NSDictionary] {
            let imageUrlString = photos[0].valueForKeyPath("original_size.url") as? String
            if let imageUrl = NSURL(string: imageUrlString!) {
                cell.photoImage.setImageWithURL(imageUrl)
            }
        }
        return cell
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! PhotoDetailsViewController
        let indexPath = table.indexPathForCell(sender as! UITableViewCell)
        let post = posts[indexPath!.row]
        
        if let photos = post.valueForKey("photos") as? [NSDictionary] {
            let imageUrlString = photos[0].valueForKeyPath("original_size.url") as? String
            if let imageUrl = NSURL(string: imageUrlString!) {
                vc.imageUrl = imageUrl
            }
        }

    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
