//
//  MemeItemsTableViewController.swift
//  MemeMe
//
//  Created by Brian Moriarty on 4/7/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import UIKit

//
// MemeItemsTableViewController
// Displays memes in a table view.
//
class MemeItemsTableViewController: MemeItemsViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var meme = memes?[indexPath.item]
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableItem", forIndexPath: indexPath) as MemeTableViewCell        
        cell.meme = meme
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    //
    // On row selection, displays the static meme viewer containing the memed image.
    //
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MemeTableViewCell {
            // the selection may have changed the imageview background, 
            // we change it back because we think this makes the table look more balanced.
            cell.memeImageView?.backgroundColor = cell.originallyConfiguredColor
        }
        handleSelectionEventForMemeAtIndex(indexPath.item)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        handleDeselectionEventForMemeAtIndex(indexPath.item)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            deleteSingleMemeAtIndex(indexPath.item)
        }
    }
    
    // MARK: Implement Abstract Overrides
    
    //
    // ask table view to reload data
    //
    override func refreshMemesDisplay() {
        tableView.reloadData()
    }
    
    override func editModeChanged() {
        if let tableView = tableView {
            tableView.allowsMultipleSelection = editMode
            tableView.editing = editMode
        }
    }
    
    override func selectedMemes() -> [Meme] {
        return memesAtPaths(tableView.indexPathsForSelectedRows() as? [NSIndexPath])
    }
 
}
