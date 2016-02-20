//
//  MemeItemsViewController.swift
//  MemeMe
//
//  Created by Brian Moriarty on 4/5/15.
//  Copyright (c) 2015 Brian Moriarty. All rights reserved.
//

import UIKit

//
// MemeItemsViewController
// Abstract Base class for our Meme Items controllers.
// Sub classses MUST override reloadMemes()
//
// MARK: - MemeItemsViewController
class MemeItemsViewController: UIViewController {
    
    let CollectionCellsPerRowLandscape = 5
    let CollectionCellsPerRowPortrait = 3
    
    // CODE: set as 2 in IB, not sure how to reference that value in code, so keep this in sync
    let CollectionCellSpacing = 2
    
    // MARK: Outlets and Properties
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var collectionView: UICollectionView?
    
    var memes: [Meme]?
    
    // we only want to force the editor to show if the app opens to an empty list,
    // after the user browses around, cancels or deletes all items, we let them see the empty list.
    private var shouldSegueToEditor = false
    
    // mode permits interacting with the meme list
    var editMode: Bool = false {
        didSet {
            editModeChanged()
        }
    }
    
    private var defaultCount: Int?
    private var collectionCellCountPerRow: Int {
        let orientation = UIDevice.currentDevice().orientation
        switch orientation {
        case .LandscapeLeft, .LandscapeRight:
            defaultCount = CollectionCellsPerRowLandscape
            return CollectionCellsPerRowLandscape
        case .Portrait:
            defaultCount = CollectionCellsPerRowPortrait
            return CollectionCellsPerRowPortrait
        default:
            return defaultCount ?? CollectionCellsPerRowPortrait
        }
    }

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // left side edit button / right side [+] button
        navigationItem.leftBarButtonItem = produceEditButton()
        navigationItem.rightBarButtonItem = produceAddMemeButton()
        
        // get memes array from the AppDelegate
        reloadMemesFromSource()
        
        // if we have no memes, segue to the editor
        if let count = memes?.count where count == 0 {
                shouldSegueToEditor = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // we always want to start outside of edit mode
        if editMode {
            disableEditModeAction(self)
        }
        
        // copy memes from AppDelegate, maybe some memes changed
        reloadMemesFromSource()
        
        // tell the display to update itself from the now up to date meme data
        refreshMemesDisplay()
        
        // enable the left "Edit" button if there are more than 0 memes
        navigationItem.leftBarButtonItem?.enabled = memes?.count > 0
    }
    
    override func viewDidAppear(animated: Bool) {
        // we only want to segue to the editor on first load,
        // after that we let the user see an empty list
        // **  to segue directly from viewDidLoad is reportedly not good practice
        if shouldSegueToEditor {
            shouldSegueToEditor = false
            performSegueWithIdentifier("MemeEditorSegue", sender: self)
        }
    }
    
    override func viewWillLayoutSubviews() {
        calculateCollectionCellSize()
    }
    
    // calculates cell size based on cells-per-row for the current device orientation
    private func calculateCollectionCellSize() {
        if let collectionView = collectionView {
            let width = collectionView.frame.width / CGFloat(collectionCellCountPerRow) - CGFloat(CollectionCellSpacing)
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            layout?.itemSize = CGSize(width: width, height: width)
        }
    }
    
    // MARK: Actions
    
    // action performed when [+] button tapped
    // segue to Meme Editor
    func addMemeAction(sender: AnyObject!) {
        performSegueWithIdentifier("MemeEditorSegue", sender: self)
    }
    
    // action performed when "Edit" button tapped
    // change bar button items for edit mode (Cancel / Delete)
    func enableEditModeAction(sender: AnyObject!) {
        editMode = true
        navigationItem.leftBarButtonItem = produceCancelButton()
        navigationItem.rightBarButtonItem = produceDeleteButton()
        navigationItem.rightBarButtonItem?.enabled = false
        editModeChanged()
    }
    
    // action performed when "Cancel" button is tapped
    // toggle out of edit mode, replacing regular mode bar buttons.
    func disableEditModeAction(sender: AnyObject!) {
        editMode = false
        navigationItem.leftBarButtonItem = produceEditButton()
        navigationItem.rightBarButtonItem = produceAddMemeButton()
        editModeChanged()
    }

    // delete all currently selected memes and update the display
    func deleteSelectedMemesAction(sender: AnyObject!) {
        let selected = selectedMemes()
        if let newMemes = memes?.filter({ !selected.contains($0) }) {
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes = newMemes
            memes = appDelegate.memes
            disableEditModeAction(self)
            refreshMemesDisplay()
        }
    }
    
    // MARK: Helpers
    
    // copy memes array from the AppDelegate
    private func reloadMemesFromSource() {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
    }
    
    // delete the meme from the AppDelegate Meme array and update views
    func deleteSingleMemeAtIndex(index: Int) {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.removeAtIndex(index)
        memes = appDelegate.memes
        refreshMemesDisplay()
    }
    
    // return the meme objects at the indices specified in by the indexPaths array
    func memesAtPaths(indexPaths: [NSIndexPath]?) -> [Meme] {
        var result: [Meme] = [Meme]()
        if let indexPaths = indexPaths, memes = memes {
            result = indexPaths.map() { memes[$0.item] }
        }
        return result
    }
    
    // MARK: Abstracted Event Handling 
    
    // Instantiate viewcontroller with ID = MemeStaticViewer from storyboard.
    // Push with navigation controller to display.
    func handleSelectionEventForMemeAtIndex(index: Int) {
        if let memes = memes where !editMode && index < memes.count {
            let meme = memes[index]
            let singleMemeViewer = storyboard?.instantiateViewControllerWithIdentifier("MemeStaticViewer") as! SingleMemeViewController
            singleMemeViewer.meme = meme
            navigationController?.pushViewController(singleMemeViewer, animated: true)
        } else {
            selectionChanged()
        }
        
    }
    
    // when deselected, call selectionChanged() to handle additional actions
    func handleDeselectionEventForMemeAtIndex(index: Int) {
        selectionChanged()
    }
    
    // when in edit mode, enable or disable the "Trash" button appropriately if at least 1 meme is selected
    func selectionChanged() {
        if (editMode) {
            navigationItem.rightBarButtonItem?.enabled = selectedMemes().count > 0
        }
    }
    
    // MARK: UIBarButonItem Producers
    
    // return configured [+] button
    private func produceAddMemeButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addMemeAction:")
    }
    
    // return configured "Edit" button
    private func produceEditButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "enableEditModeAction:")
    }
    
    // return configured "Cancel" button
    private func produceCancelButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "disableEditModeAction:")
    }
    
    // return configured "Trash" button
    private func produceDeleteButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "deleteSelectedMemesAction:")
    }
    
    // MARK: Container Specific Methods
    
    // subclasses should override to to perform appropriate actions when meme data needs to be reloaded.
    func refreshMemesDisplay() {
        tableView?.reloadData()
        collectionView?.reloadData()
    }
    
    // subclasses should override to perform appropriate actions when edit mode is toggled
    func editModeChanged() {
        if let tableView = tableView {
            tableView.allowsMultipleSelection = editMode
            tableView.editing = editMode
        } else if let collectionView = collectionView {
            collectionView.allowsMultipleSelection = editMode
            if (!editMode) {
                if let indexPaths = collectionView.indexPathsForSelectedItems() {
                    for indexPath in indexPaths {
                        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
                    }
                }
            }
        }
    }
    
    // return the list of selected memes
    func selectedMemes() -> [Meme] {
        if let tableView = tableView,
            indexPaths = tableView.indexPathsForSelectedRows {
            return memesAtPaths(indexPaths)
        } else if let collectionView = collectionView,
            indexPaths = collectionView.indexPathsForSelectedItems() {
            return memesAtPaths(indexPaths)
        } else {
            return [Meme]()
        }
    }
}

// MARK: - UITableViewDelegate
extension MemeItemsViewController: UITableViewDelegate {

    // On row selection, displays the static meme viewer containing the memed image.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
}

// MARK: - UITableViewDataSource
extension MemeItemsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let meme = memes?[indexPath.item]
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableItem", forIndexPath: indexPath) as! MemeTableViewCell
        cell.meme = meme
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MemeItemsViewController: UICollectionViewDelegate {
    // On cell selection displays the static meme viewer.
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        handleSelectionEventForMemeAtIndex(indexPath.item)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        handleDeselectionEventForMemeAtIndex(indexPath.item)
    }
}

// MARK: - UICollectionViewDataSource
extension MemeItemsViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionItem", forIndexPath: indexPath) as! MemeCollectionViewCell
            cell.meme = memes?[indexPath.item]
            return cell
    }
}




