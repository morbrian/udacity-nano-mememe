//
//  MemeItemsTableViewController.swift
//  MemeMe
//
//  Created by Brian Moriarty on 4/7/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import UIKit

class MemeItemsTableViewController: MemeItemsViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var meme = memes[indexPath.item]
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableItem", forIndexPath: indexPath) as MemeTableViewCell
        cell.meme = meme
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        showStaticViewerForMeme(memes[indexPath.item])
    }
    
    // MARK: Implement Abstract Overrides
    
    //
    // ask table view to reload data
    //
    override func reloadMemes() {
        tableView.reloadData()
    }
    
}
